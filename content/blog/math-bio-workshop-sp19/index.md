---
title: 'Mathematical Biology Numerics Workshop'
tags: ["Python", "Math", "DataViz"]
date: 2019-01-25T13:12:00-04:00
mathJaxMacros:
draft: false
---

Below is the output from running [this notebook on Google Colab](https://colab.research.google.com/drive/10gO3YtqhnPL0u5Gnq313LlEW6g3Vm6Vq); you'll need to select "open in playground" to make changes or run cells.

We will consider the solution of the problem
\begin{align}
\dot{x}(t) = f(t, x, u),
\end{align}
\begin{align}
  x(t_0) = x^0 \in \mathbb{R}^n
\end{align}
where
\begin{align}
  x(t) = \big( x_1(t), x_2(t), \ldots, x_n(t)\big)
\end{align}
is the state vector,
\begin{align}
  u = \big( u_1, u_2, \ldots, u_m\big) \in \mathbb{R}^m
\end{align}
is the parameter vector, and
\begin{align}
  f(t,x,u) = \big(
  f_1(t, x, u), f_2(t, x, u),\ldots, f_n(t, x, u)\big):
  [t_0, T] \times \mathbb{R}^n \times \mathbb{R}^m \to \mathbb{R}^n
\end{align}

Suppose that, while we know the model governing the system (i.e. we know `f`), we don't have precise information on the coefficients; to compensate for this loss of information, we will take an additional measurement, which we will take to be the state vector information throughout the time interval $[t_0, T]$.

Abdulla & Poteau (Mathematical Biosciences, 2018) suggests the methods of quasilinearization and Tikhonov regularization, since the system is in general nonlinear and may have a complicated dependence on $x$ and $u$; below we will give an implementation of the method for the classical Lotka-Volterra system
\begin{align}
\dot{x}_1 = u_1 x_1 - u_2 x_1 x_2
\end{align}
\begin{align}
\dot{x}_2 =  u_2 x_1 x_2 - u_3 x_2
\end{align}

The derivation of the system below is outside the scope of this post, but more details can be found in the notebook linked above.
This problem is small enough in scale that writing the linearization "by hand" is feasible, so that aside from a few trouble spots, the translation of the algorithm from a mathematical statement to a computational one is relatively straightforward.
If you're interested in working on improving the numerical treatment and ergonomics of this code, or in establishing theoretical results regarding these types of problems, come work with us!

We'll use the NumPy, SciPy, and Matplotlib packages to do the computation and visualization for this algorithm:

```python
import numpy as np
from scipy.integrate import solve_ivp
from scipy.integrate import trapz
from scipy.interpolate import interp1d
```

We will define a few helper functions to evaluate the right-hand side of the quasilinearized ODE in an idiomatic way:


```python
def lotkaVolterraF(t, x, u):
    return np.array([
        u[0]*x[0] - u[1]*x[0]*x[1],
        u[1]*x[0]*x[1] - u[2]*x[1]
    ])
# print(lotkaVolterraF(0, [-1, 1], [0, 0, 0]))

# df/dx
def lotkaVolterraJ(t, x, u):
    return np.array([
        [u[0] - u[1]*x[1], -u[1]*x[0]],
        [u[1]*x[1], u[1]*x[0] - u[2]]
    ])

# print(lotkaVolterraJ(0, [-1, 1], [0, 0, 0]))

# df/du
def lotkaVolterraUDeriv(t, x, u):
    return np.array([
        [x[0], -x[0]*x[1], 0],
        [0, x[0]*x[1], -x[1]]
    ])

# print(lotkaVolterraUDeriv(0, [-1, 1], [0, 0, 0]))
```


```python
def quasilinearLotkaVolterra(t, xN, xNMinus, u):
    fv = lotkaVolterraF(t, xNMinus, u)
    J = lotkaVolterraJ(t, xNMinus, u)
    return fv + J @ (xN - xNMinus)

# print(quasilinearLotkaVolterra(0, np.array([-1, 1]), np.array([0, 0]), [1, 1, 1]))
```

The function above computes the right-hand side of the quasilinearized system
\begin{align}
\dot{x}\_N(t)
 = \text{quasilinearLotkaVolterra}(
 t,
 x\_{N},
 x\_{N-1},
 u)
\end{align}

We'll also need to calculate the right-hand side of the matrix DE defining $U_N$:


```python
def lotkaVolterraBMatrix(t, x, u):
    return np.array([
        [1, 0],
        [-x[1], -x[0]],
        [0, 0]
    ])

def lotkaVolterraCMatrix(t, x, u):
    return np.array([
        [0, 0],
        [x[1], x[0]],
        [0, -1]
    ])

def lotkaVolterraUNF(t, xN, xNMinus, UN, u):
    tmpRhs = lotkaVolterraUDeriv(t, xNMinus, u)
    tmpRhs[0, ...] += lotkaVolterraBMatrix(t, xNMinus, u) @ (xN - xNMinus)
    tmpRhs[1, ...] += lotkaVolterraCMatrix(t, xNMinus, u) @ (xN - xNMinus)
    return tmpRhs + lotkaVolterraJ(t, xNMinus, u) @ UN

# print(lotkaVolterraUNF(
#     t = 0,
#     xN = np.array([1, 1]),
#     xNMinus = np.array([2, 2]),
#     UN = np.array([[0, 1, 2], [3, 4, 5]]),
#     u = [0, 0, 0]))
```

The method above computes the right-hand side of the equation
\begin{align}
\dot{U}\_N(t) = \text{lotkaVolterraUNF}(t, x\_N, x\_{N-1}, U\_N, u\_N)
\end{align}

Below we'll define some convenience functions for transforming our combined vector + matrix state information into a single vector and vice-versa.

This is required to interface with an ODE solver like RK4, and requires us to think about the whole system of unknowns as a group; define a new zero-indexed state vector $v=\big( v\_0, v\_1, \ldots, v\_7\big)$ and identify $(v\_0, v\_1) = (x\_{N, 1}, x\_{N, 2})$ and $(v\_2,\ldots,v\_7)$ with $U\_N$ in row-major order.
This corresponds to the default action of `np.ravel`, but should be recalled whenever referring to indices in $U\_N$.

```python
# Convenience method for concatenating quasilinearized state variables
def to_vec(x, UN):
    return np.concatenate(
        (
            x,
            np.ravel(UN)
        )
    )

# # Example
# UN = np.array([
#     [1, 2, 3],
#     [4, 5, 6]
# ])
# x = np.array([-1, 0])

# v = to_vec(x, UN)

# # Check that it works as expected
# assert all(v[0:2] == x)
# assert len(v) == len(x) + UN.size
```

The above function has a nearly trivial inverse; having both defined makes translating between the algorithm's notation and the required notation in Python a bit easier:

```python
# Convenience method for unconcatenating quasilinearized state variables
# Note n=2 (number of state variables)
# and m=3 (number of control variables)
def to_vals(v):
    x = v[0:2] # Python ranges don't include the right endpoint...
    UN = v[2:].reshape(2, 3)
    return (x, UN)

# # Example
# (x1, UN1) = to_vals(v)

# # Check that it works as expected
# assert all(x1 == x)
# assert (UN1 == UN).all()
```

Having the previous definitions, we can now integrate the quasilinearized Lotka-Volterra system.
See [here](https://docs.scipy.org/doc/scipy/reference/generated/scipy.integrate.solve_ivp.html#scipy.integrate.solve_ivp) for documentation on `solve\_ivp`, and [here](https://docs.scipy.org/doc/scipy-1.2.0/reference/generated/scipy.interpolate.interp1d.html#scipy.interpolate.interp1d) for documentation on the interpolation routine.


```python
def lotkaVolterraSoln(tspan, npts, x0, u, xNMinus = None):
    tgrid = np.linspace(tspan[0], tspan[1], num = npts)
    if xNMinus is None:
        xNMinus = np.array([x0 for t in tgrid])

    xNMinusSpline = interp1d(tgrid, xNMinus, axis=0, fill_value = 'extrapolate', copy = False, assume_sorted = True)

    # TODO: Provide `jac` argument to solver
    return solve_ivp(
        fun = lambda t, x: quasilinearLotkaVolterra(t, x, xNMinusSpline(t), u),
        t_span = tspan,
        y0 = x0,
        t_eval = tgrid
    )

# Example
x0 = np.array([1, 1])
u = [1, 2, 1]
tspan = (0, 1)
xFine = lotkaVolterraSoln(tspan, 10000, x0, u)

# Check that the output makes sense
assert len(xFine.t) == 10000
# The y component has `n` components in the first axis
# and len(tgrid) components in the second axis
assert xFine.y.shape == (2, 10000)
# Integration completed successfully
assert xFine.status == 0 and xFine.success

# Check for convergence of quasilinearization: calculate x_2, x_3, and x_4 given
# the prior output as x_1.
xFine2 = lotkaVolterraSoln(tspan, 10000, x0, u, xFine.y.T)
xFine3 = lotkaVolterraSoln(tspan, 10000, x0, u, xFine2.y.T)
xFine4 = lotkaVolterraSoln(tspan, 10000, x0, u, xFine3.y.T)
assert np.linalg.norm(xFine2.y - xFine.y) > np.linalg.norm(xFine3.y - xFine2.y)
assert np.linalg.norm(xFine3.y - xFine2.y) > np.linalg.norm(xFine4.y - xFine3.y)
```

We can use `matplotlib` to visualize the output:

```python
from matplotlib import pyplot as plt
ax1 = plt.subplot(311)
plt.plot(xFine.t, xFine.y.T)
plt.title('x_1')
plt.ylabel('x')

plt.subplot(312, sharex = ax1, sharey = ax1)
plt.title('x_4')
plt.ylabel('x')
plt.plot(xFine4.t, xFine4.y.T)

plt.subplot(313)
plt.title('x_1 - x_4')
plt.xlabel('t')
plt.ylabel('x')
plt.plot(xFine4.t, (xFine.y.T - xFine4.y.T))

plt.subplots_adjust(hspace=0.7)

plt.suptitle('Numerical Solution of Lotka-Volterra System');
```


![png](/blog/math-bio-workshop-sp19/AbdullaPoteauExample_13_0.png)


This agrees qualitatively with the results in Abdulla & Poteau (2018) (after only one linear step, no less!) which suggests the problem setup code we wrote is correct enough to proceed with the gradient descent portion of the code.

For our purposes, no measurements are available.
Therefore, we will fix some "exact" parameter values $u$ as `uTrue`, and solve our quasilinear system on a fine grid until we have some kind of convergence in the output values; the result will be taken as our "measurement" $x(t, u)$ (`xTrue`).


```python
def quasilinearSystemLimit(tspan, npts, x0, u, tolerance, max_iterations = 20):
    tgrid = np.linspace(tspan[0], tspan[1], num=npts)
    xPrev = np.array([x0 for t in tgrid]) # Naive initialization using constant data
    xNext = xPrev.copy() + 1
    its = 0
    while np.linalg.norm(xNext - xPrev) > tolerance and its < max_iterations:
        solOut = lotkaVolterraSoln(tspan, npts, x0, u, xPrev)
        xPrev = xNext
        xNext = solOut.y.T
        its += 1

    return solOut.t, xNext
# # Example
# x0 = np.array([1, 1])
# u = [1, 2, 1]
# tspan = (0, 1)

# %timeit quasilinearSystemLimit(tspan, 10000, x0, u, 1e-6)
# tgridTrue, xTrue = quasilinearSystemLimit(tspan, 10000, x0, u, 1e-6)
# uTrue = u
# xTrueSpline = interp1d(tgridTrue, xTrue, axis=0, fill_value = 'extrapolate', copy = False, assume_sorted = True)
```

In my experiments, this converged in 14 steps (and took ~50ms to do so: see [`%timeit`](https://ipython.readthedocs.io/en/stable/interactive/magics.html#magic-timeit) to do your own testing.)

We'll also need a method that calculates a pair $(U\_N, x\_N)$ given $(\text{tgrid}, x0, u\_{N-1}, x\_{N-1})$; having this, we can calculate the update $\Delta u$ according to eq. (10) of Abdulla and Poteau.

```python
def lotkaVolterraCombinedRhs(t, vN, xNMinus, u):
    xN, UN = to_vals(vN)
    output = to_vec(
        quasilinearLotkaVolterra(t, xN, xNMinus, u),
        lotkaVolterraUNF(t, xN, xNMinus, UN, u)
    )
    return output

def calculateUpdateDE(tgrid, x0, uNMinus, xNMinus):
    # Initial data for combined (x_N, u_N) system
    v0 = to_vec(x0, np.zeros((2, 3)))

    ## Calculate x_N, U_N

    # Assume xNMinus is the same length as tgrid
    xNMinusSpline = interp1d(tgrid, xNMinus, axis=0, fill_value = 'extrapolate', copy = False, assume_sorted = True)

    # TODO: Provide `jac` argument to solver; this solver can't make
    # efficient (explicit) use of the linearity with respect to x
    solverOutput = solve_ivp(
        fun = lambda t, v: lotkaVolterraCombinedRhs(t, v, xNMinusSpline(t), uNMinus),
        t_span = tspan,
        y0 = v0,
        t_eval = tgrid
    )

    # Transform back to vector of (x_n, U_N) pairs
    return [to_vals(v) for v in solverOutput.y.T]
```

We'll be using the spline `xTrueSpline` defined above, as well as `x0` and `uTrue`.
Take the same initial approach as the corresponding example in Abdulla and Poteau (2018)


```python
# Residue approximation
def ResidueApprox(tgrid, xTrue, xN):
    dxTmp = [xTrue(t) - xN_and_UN[i][0] for i, t in enumerate(tgrid)]
    return trapz(pow(np.linalg.norm(dxTmp, axis=1), 2), tgrid)

# Define the functional
def J(tgrid, dx, UN, du):
    # Calculate vector of norms of dx (len(tgrid) x 2) - UN (len(tgrid) x 2 x 3) * du (3x1)
    # Setting axis=1 selects the direction over which we will broadcast the norm
    # operation.
    return trapz(pow(np.linalg.norm(dx - UN @ du, axis=1), 2), tgrid)

# # Calculate declination from measurement
# dxVals = [xTrueSpline(t) - xN_and_UN[i][0] for i, t in enumerate(tgrid)]

# # Extract U_N component
# UN = np.array([v[1] for v in xN_and_UN])

# # Check that we can calculate the approximate residue
# print(ResidueApprox(tgrid, xTrueSpline, [v[0] for v in xN_and_UN]))

# # Check that we can evaluate our functional (taking du = uNMinus)
# print(J(tgrid, dxVals, UN, uNMinus))
# print(J(tgrid, dxVals, UN, [1, 2, 1]))
```

We can also calculate the weight matrix defining $\Delta u$ (which we call `du`) which is denoted by $A\_N$ (and calculated using our routine `AN`)


```python
#TODO: Implement trapz with arbitrary codomain
def rightEndpoint(tgrid, yValues):
    output = np.zeros_like(yValues[0])
    # integrate.trapz only handles functions with codomain R?!
    # So instead we use a simple Riemann sum formulation.
    for (i, y) in enumerate(yValues):
        if i == 0:
            continue
        output += (tgrid[i] - tgrid[i-1]) * y
    return output

def AN(tgrid, UN):
    # The first axis of UN is time-like, with the remaining axes being the 2D U_n
    # matrices. Below we shuffle the axes of UN so each 2d matrix is U_N^T
    yValues = np.transpose(UN, (0, 2, 1)) @ UN
    return rightEndpoint(tgrid, yValues)

# print(AN(tgrid, UN))
```

We define the right-hand side of the linear system, denoted by $P\_N$ (and calculated using our routine `PN`)


```python
def PN(tgrid, UN, dx):
    return rightEndpoint(tgrid, [np.transpose(U) @ dx for (U, dx) in zip(UN, dx)])

# print(PN(tgrid, UN, dxVals))
```

We can then calculate the update $\Delta u$ (our `deltaU`) which completes the algorithm.


```python
def deltaU(tgrid, UN, dxVals):
    return np.linalg.solve(AN(tgrid, UN), PN(tgrid, UN, dxVals))

# print(deltaU(tgrid, UN, dxVals))
```

## Complete Algorithm Implementation
All that remains is to connect the pieces we've implemented here into a single function that comprises the whole algorithm as described in Abdulla & Poteau

0) Takes a pair $(u\_0, x\_0)$, sets $N=1$,

1) Simultaneously produces $x_N$ and the sensitivity matrix $U_N$ based on the quasilinear Lotka Volterra system and the DE representing the sensitivity of each state variable to changes in each parameter.

2) Solve the linear system above to find the increment $\Delta u$ corresponding to a stationary point of the functional `J` defined above, and update $u\_N = u\_{N-1} + \Delta u$, and

3) Stop iterating if a stopping condition is reached.

The methods below implement a single calculation of $\Delta u$, and use that increment to iteratively update the parameter vector `uN` until the update becomes sufficiently small in norm:
```python
def gradientStep(tgrid, x0, uNMinus, xNMinus, xTrueSpline):
    # Update x_N(t) and U_N(t)
    xN_and_UN = calculateUpdateDE(tgrid, x0, uNMinus, xNMinus)

    # Extract x_N component
    xN = np.array([xi[0] for xi in xN_and_UN])

    # Calculate declination from measurement
    dxVals = [xTrueSpline(t) - xN[i] for i, t in enumerate(tgrid)]

    # Extract U_N component
    UN = np.array([v[1] for v in xN_and_UN])

    deltaU = np.linalg.solve(AN(tgrid, UN), PN(tgrid, UN, dxVals))
    return xN, deltaU

def solve(tgrid, x0, uNMinus, xNMinus, xTrueSpline, tolerance=1e-6, NMax = 100):
    N = 1
    uN = uNMinus.copy()
    xN = xNMinus.copy()

    while N < NMax:
        xN, deltaU = gradientStep(tgrid, x0, uNMinus, xNMinus, xTrueSpline)

        uN = uNMinus + deltaU
        uNMinus = uN
        xNMinus = xN

        N += 1
        if np.linalg.norm(deltaU) < tolerance:
            print('Converged.')
            break

    return xN, uN, N
```

Having that, we can complete the rest of the example (which requires choosing a time span, starting point, calculating synthetic data, etc.)

```python
# Fixed values
x0 = np.array([1, 1])
tspan = (0, 1)
tgrid = np.linspace(tspan[0], tspan[1], num=100)

# Synthetic data
uTrue = np.array([1, 2, 1])
tgridTrue, xTrue = quasilinearSystemLimit(tspan, 10000, x0, uTrue, 1e-6)
xTrueSpline = interp1d(tgridTrue, xTrue, axis=0, fill_value = 'extrapolate', copy = False, assume_sorted = True)

# Initial approach for parameter
uNMinus = np.array([6, 7, 6])

# Initial guess for corresponding state vector.
# This is not explicitly mentioned in the paper, but the measurement
# function "exists" without knowing the true parameter value,
# ostensibly, which makes it a good guess.
xNMinus = np.array([xTrueSpline(t) for t in tgrid])

# Run gradient descent routine
xN, uN, N = solve(tgrid, x0, uNMinus, xNMinus, xTrueSpline)

# Give some output
print(N)
print(uN)
```

    Converged.
    10
    [0.99828489 1.99887645 0.99922541]

We can see that the resulting parameter vector $u\_N$ printed above is quite close to the "true" vector, with an absolute error of `2e-3`.
