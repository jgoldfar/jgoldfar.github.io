using Libical

## Libical helpers
struct simpleEvent
    title::String
    startTime::String
    endTime::String
end

import Base: show
Base.show(io::IO, e::simpleEvent) = show(io, string(e.startTime, "-", e.endTime, ":&nbsp;", e.title))

using Dates

function find_prop(c, name)
    for prop in Libical.properties(c, name)
        if Libical.name(prop) == name
            return Libical.value(prop)
        end
    end
    return ""
end

function add_to_days_of_week!(c, summary, mEvents, tEvents, wEvents, rEvents, fEvents)
    
end

## Unused: 
# const oldDTFormat = dateformat"yyyymmdd"
## All other datetime values are formatted as below:
const newDTFormat = dateformat"yyyymmddTHHMMSSZ"
function parse_schedule_to_week(filein, startDate)
    sched = read(filein, Component)
    @assert Libical.kindString(sched) == "VCALENDAR"
    
    mEvents = simpleEvent[]
    tEvents = simpleEvent[]
    wEvents = simpleEvent[]
    rEvents = simpleEvent[]
    fEvents = simpleEvent[]
    
    endDate = startDate + Dates.Day(5)
    
    for component in Libical.components(sched)
        if Libical.kindString(component) != "VEVENT"
            continue
        end
        
        # TODO: try parsing as date (unlikely) in the format
        # YYYYMMDD
        # Then, try parsing as datetime in format
        # YYYYMMDDTHHMMSSZ
        # Given the relative likelihood of the two options, probably start with
        # the latter.
        dtstarttmp = find_prop(component, "DTSTART")
        dtstart = DateTime(dtstarttmp, newDTFormat)
        
        dtendtmp = find_prop(component, "DTEND")
        dtend = DateTime(dtendtmp, newDTFormat)

        summary = find_prop(component, "SUMMARY")
        if dtstart >= startDate && dtend <= endDate
            add_to_days_of_week!(component, summary, mEvents, tEvents, wEvents, rEvents, fEvents)
        end
            
        @show dtstart, dtend, summary
    end
    @show startDate, endDate
    
    mEvents, tEvents, wEvents, rEvents, fEvents
end

## Fixed strings in output

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

## Output routines
function printOneDay(io, dayContent::Vector{String} = String[])
    println(io, "<td>")
    if !isempty(dayContent)
        join(io, dayContent, "\n<br />")
    end
    println(io, "\n</td>")
    return nothing
end
function printOneDay(io, dayContent::Vector{simpleEvent} = simpleEvent[])
    stringEvents = String[string(e) for e in dayContent]
    printOneDay(io, stringEvents)
end

function printOneWeek(io, title, content::NTuple{5, T}) where {T}
    println(io, "<tr>")
    println(io, "<td><strong>", title,"</strong></td>")
    for c in content
        printOneDay(io, c)
    end
    println(io, "</tr>")
    return nothing
end

function printUsage(io::IO)
    fname = basename(@__FILE__)
    println(io, "usage: julia $(fname) CourseApptSchedule.ical SeminarSchedule.ical\n",
    "\tCourseApptSchedule.ical should contain all courses taught and office hours.\n",
    "\tSeminarSchedule.ical should contain all recurring/public-knowledge")
end

function main(io::IO = stdout)
    # Check arguments to script
    if length(ARGS) < 2
        printUsage(stderr)
        return nothing
    end
    CourseApptScheduleFile = ARGS[1]
    isfile(CourseApptScheduleFile) || (printUsage(stdErr); return nothing)
    SeminarScheduleFile = ARGS[2]
    isfile(SeminarScheduleFile) || (printUsage(stdErr); return nothing)
    
    thisMonday = Dates.firstdayofweek(Dates.now())
    CourseApptSchedule = parse_schedule_to_week(CourseApptScheduleFile, thisMonday)
    SeminarSchedule = parse_schedule_to_week(SeminarScheduleFile, thisMonday)
    
    # print(io, prefix)
#     printOneWeek(io, "Teaching", CourseApptSchedule)
#     printOneWeek(io, "Seminar", SeminarSchedule)
#     print(io, postfix)
    return nothing
end

main()