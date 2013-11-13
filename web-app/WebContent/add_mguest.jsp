<%@page import="db.DBConnection"%>
<%@page import="sql.*"%>
<%@page import="java.util.*"%>
<%@page import="helper.*"%>
<jsp:useBean id="dbaccess" class="db.DBAccess" scope="session" />
<jsp:useBean id="usersession" class="helper.UserSession" scope="session" />
<jsp:useBean id="ldap" class="ldap.LDAPAuthenticate" scope="session" />
<!doctype html>
<html lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html" charset="utf-8" />
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Add Meeting Guest</title>
<link rel="icon" href="http://www.cssreset.com/favicon.png">
<link rel="stylesheet" type="text/css" media="all" href="css/fonts.css">
<link rel="stylesheet" type="text/css" media="all" href="css/themes/base/style.css">
<link rel="stylesheet" type="text/css" media="all" href="css/themes/base/jquery.ui.core.css">
<link rel="stylesheet" type="text/css" media="all" href="css/themes/base/jquery.ui.theme.css">
<link rel="stylesheet" type="text/css" media="all" href="css/themes/base/jquery.ui.datepicker.css">
<link rel="stylesheet" type="text/css" media="all" href="css/themes/base/jquery.ui.selectmenu.css">
<link rel='stylesheet' type="text/css" href='fullcalendar-1.6.3/fullcalendar/fullcalendar.css'>
<script type="text/javascript" src="http://code.jquery.com/jquery-1.9.1.js"></script>
<script type="text/javascript" src='fullcalendar-1.6.3/fullcalendar/fullcalendar.js'></script>
<script type="text/javascript" src="js/modernizr.custom.79639.js"></script>
<script type="text/javascript" src="js/ui/jquery.ui.core.js"></script>
<script type="text/javascript" src="js/ui/jquery.ui.widget.js"></script>
<script type="text/javascript" src="js/ui/jquery.ui.position.js"></script>
<script type="text/javascript" src="js/ui/jquery.ui.selectmenu.js"></script>
<script type="text/javascript" src="js/ui/jquery.ui.stepper.js"></script>
<script type="text/javascript" src="js/ui/jquery.ui.dataTable.js"></script>
<script type="text/javascript" src="js/componentController.js"></script>
<%@ include file="search.jsp" %>
<%
    //Start page validation
    String userId = usersession.getUserId();
    if (userId.equals("")) {
        response.sendRedirect("index.jsp?message=Please log in");
        return;
    }
    String message = request.getParameter("message");
    if (message == null || message == "null") {
        message="";
    }
    String m_id = request.getParameter("m_id");
    String ms_id = request.getParameter("ms_id");
    if (m_id==null || ms_id==null) {
        response.sendRedirect("calendar.jsp?message=Please do not mess with the URL");
        return;
    }
    m_id = Validation.prepare(m_id);
    ms_id = Validation.prepare(ms_id);
    if (!(Validation.checkMId(m_id) && Validation.checkMsId(ms_id))) {
        response.sendRedirect("calendar.jsp?message=" + Validation.getErrMsg());
        return;
    }
    User user = new User(dbaccess);
    Meeting meeting = new Meeting(dbaccess);
    MyBoolean myBool = new MyBoolean();    
    if (!meeting.isMeeting(myBool, ms_id, m_id)) {
        message = "Could not verify meeting status (ms_id: " + ms_id + ", m_id: " + m_id + ")" + meeting.getErrMsg("AMG01");
        response.sendRedirect("logout.jsp?message=" + message);
        return;   
    }
    if (!myBool.get_value()) {
        response.sendRedirect("calendar.jsp?message=You do not permission to access that page");
        return;
    }
    if (!user.isMeetingCreator(myBool, ms_id, userId)) {
        message = "Could not verify meeting status (ms_id: " + ms_id + ", m_id: " + m_id + ")" + user.getErrMsg("AMG02");
        response.sendRedirect("logout.jsp?message=" + message);
        return;   
    }
    if (!myBool.get_value()) {
        response.sendRedirect("calendar.jsp?message=You do not permission to access that page");
        return;
    }
    // End page validation
    
    // Start User Search
    int i = 0;
    boolean searchSucess = false;
    String bu_id = request.getParameter("searchBox");
    if (bu_id!=null) {
        bu_id = Validation.prepare(bu_id);
        if (!(Validation.checkBuId(bu_id))) {
            message = Validation.getErrMsg();
        } else {
            if (!user.isMeetingGuest(myBool, ms_id, m_id, bu_id)) {
                message = "Could not verify meeting status (ms_id: " + ms_id + ", m_id: " + m_id + ")" + user.getErrMsg("AMG03");
                response.sendRedirect("logout.jsp?message=" + message);
                return;   
            }
            // User already added
            if (myBool.get_value()) {
                message = "User already added";
            } else {
                if (!user.isUser(myBool, bu_id)) {
                    message = user.getErrMsg("AMG04");
                    response.sendRedirect("logout.jsp?message=" + message);
                    return;   
                }
                // User already in Database
                if (myBool.get_value()) {   
                    searchSucess = true;
                } else {
                    // Found userId in LDAP
                    if (findUser(dbaccess, ldap, bu_id)) {
                        searchSucess = true;
                    } else {
                        message = "User Not Found";
                    }
                }
            }
        }
    }
    // End User Search
    
    if (searchSucess) {
        if (!meeting.createMeetingGuest(bu_id, ms_id, m_id, false)) {
            message = meeting.getErrMsg("AMG05");
            response.sendRedirect("logout.jsp?message=" + message);
            return;   
        } else {
            message = bu_id + " added to meeting guest list";
        }
    } else {
        String mod = request.getParameter("mod");
        String remove = request.getParameter("remove");
        if (mod != null) {
            mod = Validation.prepare(mod);
            if (!(Validation.checkBuId(mod))) {
                message = Validation.getErrMsg();
            } else {
                if (!meeting.setMeetingGuestIsMod(mod, ms_id, m_id)) {
                    message = meeting.getErrMsg("AMG06");
                    response.sendRedirect("logout.jsp?message=" + message);
                    return;   
                }
            }  
        } else if (remove != null) {
            remove = Validation.prepare(remove);
            if (!(Validation.checkBuId(remove))) {
                message = Validation.getErrMsg();
            } else {
                if (!user.isMeetingGuest(myBool, ms_id, m_id, remove)) {
                    message = user.getErrMsg("AMG07");
                    response.sendRedirect("logout.jsp?message=" + message);
                    return;   
                } else {
                    if (myBool.get_value()) { 
                        if (!meeting.removeMeetingGuest(remove, ms_id, m_id)) {
                            message = meeting.getErrMsg("AMG08");
                            response.sendRedirect("logout.jsp?message=" + message);
                            return;   
                        } else {
                            message = remove + " was removed from guest list";
                        }                           
                    } else {
                        message = "User to be removed not in guest list";   
                    }
                }        
            }  
        }
    }
    
    ArrayList<ArrayList<String>> eventGuest = new ArrayList<ArrayList<String>>();
    if (!meeting.getMeetingGuest(eventGuest, ms_id, m_id)) {
        message = meeting.getErrMsg("AMG08");
        response.sendRedirect("logout.jsp?message=" + message);
        return;   
    }                                
%>

<script type="text/javascript">
/* TABLE */
$(screen).ready(function() {
    /* CURRENT EVENT */
    $('#addMGuest').dataTable({
            "bPaginate": false,
            "bLengthChange": false,
            "bFilter": false,
            "bSort": false,
            "bInfo": false,
            "bAutoWidth": false});
    $('#addMGuest').dataTable({"aoColumnDefs": [{ "bSortable": false, "aTargets":[5]}], "bRetrieve": true, "bDestroy": true});
    $('#tbGuest').dataTable({"sPaginationType": "full_numbers"});
    $('#tbGuest').dataTable({"aoColumnDefs": [{ "bSortable": false, "aTargets":[5]}], "bRetrieve": true, "bDestroy": true});
    $.fn.dataTableExt.sErrMode = 'throw';
    $('.dataTables_filter input').attr("placeholder", "Filter entries");
    $(".remove").click(function(){
        return window.confirm("Remove this person from list?");
    });
});
/* SELECT BOX */
$(function(){
    $('select').selectmenu();
});
</script>
</head>

<body>
<div id="page">
    <jsp:include page="header.jsp"/>
    <jsp:include page="menu.jsp"/>
    <section>
        <header> 
            <!-- BREADCRUMB -->
            <p><a href="calendar.jsp" tabindex="13">home</a> � 
                <a href="view_event.jsp?ms_id=<%= ms_id %>&m_id=<%= m_id %>" tabindex="14">view_event</a> � 
                <a href="add_mguest.jsp?ms_id=<%= ms_id %>&m_id=<%= m_id %>" tabindex="15">add_mguest</a></p>
            <!-- PAGE NAME -->
            <h1>Add Meeting Guest</h1>
            <br />
            <!-- WARNING MESSAGES -->
            <div class="warningMessage"><%=message %></div>
        </header>
        <form name="addMGuest" method="get" action="add_mguest.jsp">
            <article>
                <header>
                  <h2>Add Guest</h2>
                  <img class="expandContent" width="9" height="6" src="images/arrowDown.svg" title="Click here to collapse/expand content" alt="Arrow"/>
                </header>
                <div class="content">
                    <fieldset>
                        <div class="component">
                            <input type="hidden" name="ms_id" id="ms_id" value="<%= ms_id %>">
                            <input type="hidden" name="m_id" id="m_id" value="<%= m_id %>">  
                            <label for="searchBoxAddAttendee" class="label">Search User:</label>
                              <input type="text" name="searchBox" id="searchBox" class="searchBox" tabindex="37" title="Search user">
                              <button type="submit" name="search" class="search" tabindex="38" title="Search user"></button><div id="responseDiv"></div>                                                       
                        </div>                       
                    </fieldset>
                </div>
            </article>
            <article>
                <header id="expandGuest">
                    <h2>Meeting Guest List</h2>
                    <img class="expandContent" width="9" height="6" src="images/arrowDown.svg" title="Click here to collapse/expand content"/>
                </header>
                <div class="content">
                    <fieldset>
                        <div id="currentEventDiv" class="tableComponent">
                            <table id="tbGuest" border="0" cellpadding="0" cellspacing="0">
                                <thead>
                                    <tr>
                                        <th class="firstColumn" tabindex="16">Id<span></span></th>
                                        <th>Nick Name<span></span></th>
                                        <th>Moderator<span></span></th>
                                        <th title="Action" class="icons" align="center">Modify</th>
                                        <th width="65" title="Remove" class="icons" align="center">Remove</th>
                                    </tr>
                                </thead>
                                <tbody>
                                <% for (i=0; i<eventGuest.size(); i++) { %>
                                    <tr>
                                        <td class="row"><%= eventGuest.get(i).get(0) %></td>
                                        <td><%= eventGuest.get(i).get(2) %></td>
                                        <td><%= eventGuest.get(i).get(1).equals("1") ? "Yes" : "" %></td>
                                        <td class="icons" align="center">
                                            <a href="add_mguest.jsp?ms_id=<%= ms_id %>&m_id=<%= m_id %>&mod=<%= eventGuest.get(i).get(0) %>" class="modify">
                                            <img src="images/iconPlaceholder.svg" width="17" height="17" title="Modify Mod Status" alt="Modify"/>
                                        </a></td>
                                        <td class="icons" align="center">
                                            <a href="add_mguest.jsp?ms_id=<%= ms_id %>&m_id=<%= m_id %>&remove=<%= eventGuest.get(i).get(0) %>" class="remove">
                                            <img src="images/iconPlaceholder.svg" width="17" height="17" title="Remove user" alt="Remove"/>
                                        </a></td>
                                    </tr>
                                <% } %>
                                </tbody>
                            </table>
                        </div>
                    </fieldset>
                </div>
            </article>
            <br /><hr /><br />
            <article>
                <div class="component">
                    <div class="buttons">
                        <button type="button" name="button" id="returnButton"  class="button" title="Click here to return to event page" 
                            onclick="window.location.href='view_event.jsp?ms_id=<%= ms_id %>&m_id=<%= m_id %>'">Return to Event Page</button>                                                              
                      
                      </div>
                   </div>
            </article>
        </form>
    </section>
    <jsp:include page="footer.jsp"/>
</div>
</body>
</html>