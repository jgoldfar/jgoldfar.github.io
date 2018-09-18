using Libical

const prefix = """
---
title: Schedule
draft: false
---

<table class="pure-table pure-table-bordered" style="font-size: 0.7em">
    <thead>
        <tr>
            <th>Day</th>
            <th>M</th>
            <th>T</th>
            <th>W</th>
            <th>R</th>
            <th>F</th>
        </tr>
    </thead>

    <tbody>
"""

const postfix = """
        <td colspan=6>
            Please feel free to send an email (jgoldfar@my.fit.edu) to ask a question or arrange an appointment.
        </td>
        </tr>
    </tbody>
</table>
"""

function printOneDay(io, dayContent::Array{String})
    println(io, "<td>")
    if !isempty(dayContent)
        join(io, dayContent, "\n<br />")
    end
    println(io, "\n</td>")
    return nothing
end

function printOneWeek(io, title, monContent = String[], tueContent = String[], wedContent = String[], thuContent = String[], friContent = String[])
    println(io, "<tr>")
    println(io, "<td><strong>", title,"</strong></td>")
    printOneDay(io, monContent)
    printOneDay(io, tueContent)
    printOneDay(io, wedContent)
    printOneDay(io, thuContent)
    printOneDay(io, friContent)
    println(io, "</tr>")
    return nothing
end

function main(io::IO = stdout)
    print(io, prefix)
    printOneWeek(io, "Seminar", ["Testing..."], ["Testing As Well..."])
    print(io, postfix)
    return nothing
end

main()