decimal_date(dt::Date) = year(dt) + (dayofyear(dt)-1) / daysinyear(dt)

function decimal_date(dt::AbstractString; fmt::AbstractString = "m-d-Y")
    return decimal_date(Date(dt, fmt))
end

function calendar_date(time)
    year = floor(time)
    day = round(Int, daysinyear(year) * (time - year)) 
    return Date(Year(year)) + Day(day)
end
