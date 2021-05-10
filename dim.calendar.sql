/*
Copied from: https://wiki.postgresql.org/wiki/Date_and_Time_dimensions
*/

DROP TABLE IF EXISTS DIM.CALENDAR;
CREATE TABLE DIM.CALENDAR AS

    SELECT datum AS Date
         , EXTRACT(year FROM datum) AS Year
         , EXTRACT(month FROM datum) AS Month
           -- Localized month name
         , TO_CHAR(datum, 'TMMonth') AS MonthName
         , EXTRACT(day FROM datum) AS Day
         , EXTRACT(doy FROM datum) AS DayOfYear
           -- Localized weekday
         , TO_CHAR(datum, 'TMDay') AS WeekdayName
           -- ISO calendar week
         , EXTRACT(week FROM datum) AS CalendarWeek
         , TO_CHAR(datum, 'dd. mm. yyyy') AS FormattedDate
         , 'Q' || TO_CHAR(datum, 'Q') AS Quartal
         , TO_CHAR(datum, 'yyyy/"Q"Q') AS YearQuartal
         , TO_CHAR(datum, 'yyyy/mm') AS YearMonth
           -- ISO calendar year and week
         , TO_CHAR(datum, 'iyyy/IW') AS YearCalendarWeek
           -- Weekend
         , CASE 
           WHEN EXTRACT(isodow FROM datum) IN (6, 7) THEN 'Weekend' 
           ELSE 'Weekday' 
           END AS Weekend
           -- ISO start and end of the week of this date
         , datum + (1 - EXTRACT(isodow FROM datum))::integer AS CWStart
         , datum + (7 - EXTRACT(isodow FROM datum))::integer AS CWEnd
           -- Start and end of the month of this date
         , datum + (1 - EXTRACT(day FROM datum))::integer AS MonthStart
         , (datum + (1 - EXTRACT(day FROM datum))::integer + '1 month'::interval)::date - '1 day'::interval AS MonthEnd
      FROM (    
              SELECT '2021-01-01'::DATE + sequence.day  AS datum
                FROM generate_series(0,13149)           AS sequence(day)
            GROUP BY sequence.day
           ) DQ
  ORDER BY 1
;