<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String date = request.getParameter("date");
    if (date == null || date == "null") {
        date = "";
    }
    String day = request.getParameter("day");
    if (day == null || day == "null") {
        day = "";
    }
    String name = request.getParameter("name");
    if (name == null || name == "null") {
        name = "";
    }
    String link = request.getParameter("link");
    if (link == null || link == "null") {
        link = "";
    }
    String create = request.getParameter("create");
    if (create == null || create == "null") {
        create = "";
    }
    String start = request.getParameter("start");
    if (start == null || start == "null") {
        start = "";
    }
    String type = (String) session.getAttribute("iUserType");
    String author;
    if (type.equals("admin") || type.equals("professor")) {
        author = "original";
    } else {
        author = "random";
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel='stylesheet' type='text/css' href='css/calendar_layout.css' />
        <title>
            <%
                if (create.equals("true")) {
                    out.write("Create Event");
                } else {
                    out.write("Event Details");
                }
            %>
        </title>
        <style>
            #schedule {
                background:#C7DDFF;
                width:370px;
                height:279px;
                position:absolute;
                left:50%;
                top:50%;
                margin: -300px 0 0 -250px;
            }
            #scheduleContent {
                border: solid;
                border-width: 1px;
                margin-left: auto;
                margin-right: auto;
                text-align: left;
            }
            #overlay {
                position:fixed;
                top:0px;
                bottom:0px;
                left:0px;
                right:0px;
                background-color: rgb(255, 255, 255);
                opacity: 0.8; display: block;
            }
        </style>
        <script>
            var created = "<%=create%>";
            var date = "<%=date%>";
            var type = "<%=type%>";

            function edit() {
                document.getElementById("eName").disabled = false;
                document.getElementById("saveText").style.visibility = "hidden";
                document.getElementById("recorded").disabled = false;
                document.getElementById("whiteboard").disabled = false;
                document.getElementById("webcam").disabled = false;
                document.getElementById("date").disabled = false;
                text = document.getElementById("recURL").href;
                if (text !== "http://localhost:8080/Integration/a")
                    document.getElementById("delRec").style.visibility = "visible";
                console.log(text);
                document.getElementById("editMeeting").value = "Save";
                document.getElementById("editMeeting").onclick = save;
            }
            function deleteRec() {
                var p = confirm("Are you sure?");
                if (p) {
                    document.getElementById("recURL").href = "a";
                    document.getElementById("recURL").innerHTML = "";
                    document.getElementById("recorded").checked = false;
                    document.getElementById("delRec").style.visibility = "hidden";
                }
            }
            function save() {
                document.getElementById("eName").disabled = true;
                document.getElementById("saveText").style.visibility = "visible";
                document.getElementById("recorded").disabled = true;
                document.getElementById("whiteboard").disabled = true;
                document.getElementById("webcam").disabled = true;
                document.getElementById("date").disabled = true;
                document.getElementById("delRec").style.visibility = "hidden";
                document.getElementById("editMeeting").value = "Edit this meeting";
                document.getElementById("editMeeting").onclick = edit;
            }
            function showSched() {
                document.getElementById("overlay").style.visibility = "visible";
                document.getElementById("schedule").style.visibility = "visible";
                document.getElementById("editMeeting").disabled = true;
                document.getElementById("editSched").disabled = true;
                document.getElementById("delRec").disabled = true;
            }
            function hideSched(num) {
                if (num == 1)
                    var p = confirm("This will change the schedule for every event. Continue?")
                if (p || num == 0)
                {
                    document.getElementById("schedule").style.visibility = "hidden";
                    document.getElementById("overlay").style.visibility = "hidden";
                    document.getElementById("editMeeting").disabled = false;
                    document.getElementById("editSched").disabled = false;
                    document.getElementById("delRec").disabled = false;
                }
                if (p)
                {
                    document.getElementById("editMeeting").value = "Save";
                    document.getElementById("editMeeting").onclick = save;
                }
            }
            function addLec()
            {
                area = document.getElementById("sub1");
                el = document.createElement("input");
                el2 = document.createElement("input");
                el = area.appendChild(el);
                el2 = area.appendChild(el2);
                el.type = "text";
                el.id = "tempBox";
                el.focus();
                el.name = "sub1";
                el2.type = "button";
                el2.id = "searchBtn";
                el2.value = "Search";
                el2.onclick = searchGuest;
                document.getElementById("addGuest").value = "Save";
                document.getElementById("addGuest").onclick = (function() {
                    saveSection("addGuest");
                });
            }
            function searchGuest()
            {
                value = document.getElementById("tempBox").value;

            }
            function saveSection(button) {
                tempBox = document.getElementById("tempBox");
                tempBtn = document.getElementById("searchBtn");
                name = tempBox.value;
                area = document.getElementById(tempBox.name);
                area.removeChild(tempBox);
                area.removeChild(tempBtn);
                area.innerHTML += name + "<br/>";
                document.getElementById(button).value = "Add";
                document.getElementById(button).onclick = (function() {
                    addLec(tempBox.name, button);
                });
            }
            function cancel()
            {
                var p = confirm("Are you sure you want to cancel this meeting?");
                if (p)
                {
                    window.location.href = "calendar.jsp";
                }
            }
        </script>
    </head>
    <div id="header">
        <h1>  <%
            if (create.equals("true")) {
                out.write("Create Event");
            } else {
                out.write("Event Details");
            }
            %>
        </h1>
        <p id="layoutdims">
        </p>
    </div>
    <div class="colmask leftmenu">
        <div class="colleft">
            <div class="col1">
                <div id="content">
                    <table style="text-align:left">
                        <tr>
                            <td>Event Name:</td>
                            <td><input type="text" id="eName" name="firstname" value="Lecture" disabled="disabled"></td>
                        </tr>
                        <tr>
                            <td>Event Type:</td>
                            <td>
                                <select>
                                    <option value="Meeting">Meeting</option>
                                    <%
                                        if (type.equals("professor") || type.equals("admin") || type.equals("superadmin")) {
                                            out.write("<option value=\"Lecture\">Lecture</option>");
                                        }
                                    %>
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <td><input type="checkbox" id="webcam" name="webcam" value="Presenter webcam" checked="checked" disabled ><br></td>
                            <td>Presenter-only webcam?</td>
                        </tr>
                        <tr>
                            <td><input type="checkbox" id="whiteboard" name="whiteboard" value="Public Whiteboard" checked="checked" disabled ><br></td>
                            <td>Public Whiteboard</td>
                        </tr>
                        <tr>
                            <td><input type="checkbox" id="recorded" name="recorded" value="Recorded" checked="checked" disabled><br></td>
                            <td>Recorded</td>
                        </tr>
                        <tr>
                            <td>Recorded URL:</td>
                            <td><a id="recURL" href="http://www.yahoo.ca"><%=link%></a></td>
                            <td><button id="delRec" onclick="deleteRec()" style="visibility:hidden;" type="button">Delete</button></td>
                        </tr>
                        <tr>
                            <td>Date:</td>
                        <script>
            if (created !== "true")
                document.write("<td><input type=\"text\" id =\"date\" name =\"date\" value=\"<%=date%>\" disabled> </td>");
            else if (created === "true" && date != "")
                document.write("<td><input type=\"text\" id =\"date\" name =\"date\" value=\"<%=date%>\" disabled> </td>");
            else
                document.write("<td><input type=\"date\" id =\"date\" name =\"date\" disabled> </td>")
                        </script>
                        </tr>
                        <tr>
                            <td style="vertical-align: top;">
                                Scheduling Options:
                            </td>
                            <td>
                                <table style="background:#C7DDFF; padding:10px;">
                                    <tr>
                                        <td><strong>Interval:</strong></td>
                                        <td>Weekly</td>
                                    </tr>
                                    <tr>
                                        <td><strong>Repeats:</strong></td>
                                        <td>Every 1 week</td>
                                    </tr>
                                    <tr>
                                        <td><strong>Duration</strong></td>
                                        <td>2 hours</td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td></td>
                            <td><input type="button" id="editSched" value="Edit Schedule" onclick="showSched()"/></td>
                        </tr>
                        <tr>
                            <td>Whitelist:</td>
                            <td><a id="whitelist" href="manage_whitelist.jsp?prevPage=event_details.jsp&date=<%=date%>&day=<%=day%>&name=<%=name%>&author=<%=author%>">View</a></td>
                        </tr>
                        <tr>
                            <td><input type="button" id="editMeeting" onclick="edit()" value="Edit this meeting"/></td>
                            <td><div id="saveText" style="color:green; visibility:hidden;">Meeting settings saved</div></td>
                        </tr>
                        <tr>
                            <td>Add Guest Lecturer:</td>
                            <td>
                                <div id="sub1">

                                </div>
                                <%
                                    if (type.equals("professor") || type.equals("admin") || type.equals("superadmin")) {
                                        out.write("<input type=\"button\" id=\"addGuest\" value=\"Add\" onclick=\"addLec()\">");
                                    }
                                %>
                            </td>
                        </tr>
                    </table>
                   <% if (start.equals("true")) {
                            out.write("<br/><br/><button style=\"font-size:24pt;\" type=\"button\" name=\"start\" >Start Meeting</button>");
                        } else {
                            out.write("<br/><br/><button style=\"font-size:24pt;\" type=\"button\" name=\"start\" disabled>Start Meeting</button>");
                        }
                        if (type.equals("professor") || type.equals("admin")) {
                            out.write("<button style=\"font-size:24pt;\" type=\"button\" onclick=\"cancel()\" id=\"cancelBtn\">Cancel Meeting</button><br/><br/>");
                        } else {
                            out.write("<button style=\"font-size:24pt;\" type=\"button\" onclick=\"cancel()\"id=\"cancelBtn\" disabled>Cancel Meeting</button><br/><br/>");
                        }
                    %>
                </div>
            </div>
            <div class="col2">
                <a href="calendar.jsp"><strong>Back to Calendar</strong></a>
            </div>
        </div>
    </div>
    <div id="footer">
        This is the footer
    </div>
    <div id="overlay" style="visibility:hidden;"></div>
    <div id="schedule" style="visibility:hidden;">
        <div id="scheduleContent">
            <div class="ep-recl-dialog c2" tabindex="0" role="dialog" aria-labelledby=":2h" aria-hidden="false">
                <h3 style="padding:0 0 0 10px;">Repeat</h3>
                <div class="ep-recl-dialog-content" id=":23.editordialog">
                    <table style="padding: 0 0 0 20px;"class="ep-rec" role="presentation">
                        <tbody>
                            <tr>
                                <th>Repeats:</th>
                                <td>
                                    <select id=":2k.frequency" title="Repeats Weekly ">
                                        <option value="0" title="Daily">Daily</option>
                                        <option value="1" title="Every weekday (Monday to Friday)">Every weekday (Monday to Friday)</option>
                                        <option value="2" title="Every Monday, Wednesday, and Friday">Every Monday, Wednesday, and Friday</option>
                                        <option value="3" title="Every Tuesday, and Thursday">Every Tuesday, and Thursday</option>
                                        <option value="4" title="Weekly" selected="selected">Weekly</option>
                                        <option value="5" title="Monthly">Monthly</option>
                                        <option value="6" title="Yearly">Yearly</option>
                                    </select>
                                </td>
                            </tr>
                        </tbody>
                        <tbody>
                            <tr>
                                <th>Repeat every:</th>
                                <td>
                                    <select id=":2l.interval" title="Repeat every 17 weeks">
                                        <option value="1">1</option>
                                        <option value="2">2</option>
                                        <option value="3">3</option>
                                        <option value="4">4</option>
                                        <option value="5">5</option>
                                        <option value="6">6</option>
                                        <option value="7">7</option>
                                        <option value="8">8</option>
                                        <option value="9">9</option>
                                        <option value="10">10</option>
                                        <option value="11">11</option>
                                        <option value="12">12</option>
                                        <option value="13">13</option>
                                        <option value="14">14</option>
                                        <option value="15">15</option>
                                        <option value="16">16</option>
                                        <option value="17">17</option>
                                        <option value="18">18</option>
                                        <option value="19">19</option>
                                        <option value="20">20</option>
                                        <option value="21">21</option>
                                        <option value="22">22</option>
                                        <option value="23">23</option>
                                        <option value="24">24</option>
                                        <option value="25">25</option>
                                        <option value="26">26</option>
                                        <option value="27">27</option>
                                        <option value="28">28</option>
                                        <option value="29">29</option>
                                        <option value="30">30</option>
                                    </select>
                                    <label>weeks</label>
                                </td>
                            </tr>
                            <tr>
                                <th>Repeat on:</th>
                                <td id=":2l.checkboxes">
                                    <div> <span class="ep-rec-dow"><input id=":2l.dow0" name="SU" type="checkbox"
                                                                          aria-label="Repeat on Sunday" title=
                                                                          "Sunday" /><label for=":2l.dow0" title=
                                                                          "Sunday">S</label></span><span class="ep-rec-dow"><input id=":2l.dow1"
                                                                                                 name="MO" type="checkbox" aria-label="Repeat on Monday" title=
                                                                                                 "Monday" checked="checked"/><label for=":2l.dow1" title=
                                                                                                 "Monday">M</label></span><span class="ep-rec-dow"><input id=":2l.dow2"
                                                                                                 name="TU" type="checkbox" aria-label="Repeat on Tuesday" title=
                                                                                                 "Tuesday" /><label for=":2l.dow2" title=
                                                                                                 "Tuesday">T</label></span><span class="ep-rec-dow"><input id=":2l.dow3"
                                                                                                  name="WE" type="checkbox" aria-label="Repeat on Wednesday" title=
                                                                                                  "Wednesday" /><label for=":2l.dow3" title=
                                                                                                  "Wednesday">W</label></span><span class="ep-rec-dow"><input id=":2l.dow4"
                                                                                                    name="TH" type="checkbox" aria-label="Repeat on Thursday" title=
                                                                                                    "Thursday" /><label for=":2l.dow4" title=
                                                                                                    "Thursday">T</label></span><span class="ep-rec-dow"><input id=":2l.dow5"
                                                                                                   name="FR" type="checkbox" aria-label="Repeat on Friday" title=
                                                                                                   "Friday" /><label for=":2l.dow5" title=
                                                                                                   "Friday">F</label></span><span class="ep-rec-dow"><input id=":2l.dow6"
                                                                                                 name="SA" type="checkbox" aria-label="Repeat on Saturday" title=
                                                                                                 "Saturday" /><label for=":2l.dow6" title="Saturday">S</label></span>
                                    </div>
                                </td>
                            </tr>
                            <tr tabindex="0">
                                <th id=":2l.rstart-label">Duration:</th>
                                <td>
                                    <input id=":2l.rstart" size="10" aria-labelledby=":2l.rstart-label" autocomplete="off" value="2 hours"/>
                                </td>
                            </tr>
                            <tr>
                                <th style="vertical-align:top;"class="ep-rec-ends-th">Ends:</th>
                                <td>
                                    <span class="ep-rec-ends-opt">
                                        <input name="endson" type="radio" checked="checked" title="Ends never" />
                                        <label title="Ends never">Never</label>
                                    </span>
                                    <span></br>
                                        <input type="radio" title="Ends after a number of occurrences" />
                                        <label title="Ends after a number of occurrences">After <input id=":2l.endson_count_input" size="3" value="" title="Occurrences" />
                                            occurrences</label>
                                    </span>
                                    <span></br>
                                        <label title="Ends on a specified date">On <input size="10" value="" title="Specified date" autocomplete="off" type="date"/></label>
                                    </span>
                                </td>
                            </tr>
                        </tbody>
                        <tbody>
                            <tr>
                                <th></th>

                            </tr>
                        </tbody>
                    </table>
                </div>
                <div style="text-align: center; padding: 0 0 10px 0;" class="ep-recl-dialog-buttons">
                    <button name="ok" onclick="hideSched(1)">OK</button>
                    <button name="cancel" onclick="hideSched(0)">Cancel</button>
                </div>
            </div>
        </div>
    </div>
    <script>
            var user = "<%=type%>";
            if (user == "student") {
                document.getElementById("editMeeting").style.visibility = "hidden";
                document.getElementById("editSched").style.visibility = "hidden";
                document.getElementById("startBtn").disabled = true;
            }
            if (created === "true")
                edit();
    </script>
</html>
