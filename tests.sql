   SELECT member, facility, cost FROM
          (
          SELECT concat_ws(' ', cd.members.firstname, cd.members.surname) AS
                 member,
                 cd.facilities.facname AS facility,
                 CASE
                 WHEN cd.members.memid = 0 THEN cd.facilities.guestcost
                 ELSE cd.facilities.membercost
                 END * cd.bookings.slots AS cost
            FROM cd.members
            JOIN cd.bookings
              ON cd.members.memid = cd.bookings.memid
            JOIN cd.facilities
              ON cd.bookings.facid = cd.facilities.facid
           WHERE cast(cd.bookings.starttime AS date) = '2012-09-14'
          )
          AS bookings
    WHERE cost > 30
 ORDER BY cost DESC;
