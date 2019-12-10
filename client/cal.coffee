# { Calendar } = require('@fullcalendar/core')
# dayGridPlugin =  require('@fullcalendar/daygrid')
#
# Template.cal.onRendered ->
#     Meteor.setTimeout ->
#         calendarEl = document.getElementById('cal');
#         calendar = new Calendar(calendarEl, {
#             plugins: [ dayGridPlugin ]
#         })
#         calendar.render();
#
#     , 1000
