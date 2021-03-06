<%@page import="db.DBConnection"%>
<%@page import="sql.*"%>
<%@page import="java.util.*"%>
<%@page import="helper.*"%>
<jsp:useBean id="dbaccess" class="db.DBAccess" scope="session" />
<jsp:useBean id="usersession" class="helper.UserSession" scope="session" />
<jsp:useBean id="ldap" class="ldap.LDAPAuthenticate" scope="session" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SenecaBBB | Class Settings</title>
    <link rel="shortcut icon" href="http://www.senecacollege.ca/favicon.ico">
    <link rel="stylesheet" type="text/css" media="all" href="${pageContext.servletContext.contextPath}/${initParam.CSSDirectory}/fonts.css">
    <link rel="stylesheet" type="text/css" media="all" href="${pageContext.servletContext.contextPath}/${initParam.CSSDirectory}/themes/base/style.css">
    <link rel="stylesheet" type="text/css" media="all" href="${pageContext.servletContext.contextPath}/${initParam.CSSDirectory}/themes/base/jquery.ui.core.css">
    <link rel="stylesheet" type="text/css" media="all" href="${pageContext.servletContext.contextPath}/${initParam.CSSDirectory}/themes/base/jquery.ui.theme.css">
    <link rel="stylesheet" type="text/css" media="all" href="${pageContext.servletContext.contextPath}/${initParam.CSSDirectory}/themes/base/jquery.ui.selectmenu.css">
    <script type="text/javascript" src="${pageContext.servletContext.contextPath}/${initParam.JavaScriptDirectory}/jquery-1.9.1.js"></script>
    <script type="text/javascript" src="${pageContext.servletContext.contextPath}/${initParam.JavaScriptDirectory}/modernizr.custom.79639.js"></script>
    <script type="text/javascript" src="${pageContext.servletContext.contextPath}/${initParam.JavaScriptDirectory}/ui/jquery.ui.core.js"></script>
    <script type="text/javascript" src="${pageContext.servletContext.contextPath}/${initParam.JavaScriptDirectory}/ui/jquery.ui.widget.js"></script>
    <script type="text/javascript" src="${pageContext.servletContext.contextPath}/${initParam.JavaScriptDirectory}/ui/jquery.ui.position.js"></script>
    <script type="text/javascript" src="${pageContext.servletContext.contextPath}/${initParam.JavaScriptDirectory}/ui/jquery.ui.selectmenu.js"></script>
    <script type="text/javascript" src="${pageContext.servletContext.contextPath}/${initParam.JavaScriptDirectory}/ui/jquery.ui.stepper.js"></script>
    <script type="text/javascript" src="${pageContext.servletContext.contextPath}/${initParam.JavaScriptDirectory}/ui/jquery.ui.dataTable.js"></script>
    <script type="text/javascript" src="${pageContext.servletContext.contextPath}/${initParam.JavaScriptDirectory}/checkboxController.js"></script>
    
    <%@ include file="search.jsp" %>
    <%
    //Start page validation
    String userId = usersession.getUserId();
    GetExceptionLog elog = new GetExceptionLog();
    Boolean isProfessor = usersession.isProfessor();
    Boolean isSuper = usersession.isSuper();
    if (userId.equals("")) {
        session.setAttribute("redirecturl",request.getRequestURI() + (request.getQueryString() != null ? "?" + request.getQueryString() : ""));
        response.sendRedirect("index.jsp?message=Please log in");
        return;
    }
    if (dbaccess.getFlagStatus() == false) {
        elog.writeLog("[class_settings:] " + "database connection error /n");
        response.sendRedirect("index.jsp?message=Database connection error");
        return;
    }
    if (!isSuper && !isProfessor) {
        elog.writeLog("[class_settings:] " + " username: " + userId + " tried to access this page, permission denied" + " /n");
        response.sendRedirect("calendar.jsp?message=You don't have permissions to view that page.");
        return;
    }

    //End page validation
    String message = request.getParameter("message");
    String successMessage = request.getParameter("successMessage");
    if (message == null || message == "null") {
        message = "";
    }
    if (successMessage == null) {
        successMessage = "";
    }

    String c_id = "";
    String sc_id = "";
    String sc_semesterid = "";
    String professorid = "";
    String removeStudentId = request.getParameter("removeStudent");
    String selectedclass;

    Section section = new Section(dbaccess);
    User user = new User(dbaccess);
    Lecture lecture = new Lecture(dbaccess);
    MyBoolean myBool = new MyBoolean();
    selectedclass = request.getParameter("class");
    int profSettings = 0;
    HashMap<String, Integer> scSettingResult = new HashMap<String, Integer>();
    ArrayList<HashMap<String, String>> profList = new ArrayList<HashMap<String, String>>();
    ArrayList<HashMap<String, String>> stuList = new ArrayList<HashMap<String, String>>();

    if (selectedclass == null) {
        message = "Please choose a class to add students";
    } else if (selectedclass.split("-").length == 4) {
        c_id = selectedclass.split("-")[0];
        sc_id = selectedclass.split("-")[1];
        sc_semesterid = selectedclass.split("-")[2];
        professorid = selectedclass.split("-")[3];
        if (section.getSectionSetting(scSettingResult, c_id, sc_id,sc_semesterid, professorid)) {
            profSettings = scSettingResult.get("isRecorded");
        }
        if (section.getStudent(stuList, c_id, sc_id, sc_semesterid)) {
            if (stuList.size() == 0 && message == "")
                message = "No Student in this section!";
        } else {
            message = "Can't get information from the given section!";
        }
    } else {
        message = "Wrong section information";
        elog.writeLog("[class_settings:] " + message + "/n");
        response.sendRedirect("class_settings.jsp");
    }

    ArrayList<HashMap<String, String>> listofclasses = new ArrayList<HashMap<String, String>>();
    ArrayList<HashMap<String, String>> nickNameResult = new ArrayList<HashMap<String, String>>();
    if (isSuper) {
        section.getProfessor(listofclasses); // get every class
    } else if (isProfessor) {
        section.getProfessor(listofclasses, userId);//get classes for current professor
    } else {
        elog.writeLog("[class_settings:] " + " username: " + userId + " tried to access this page, permission denied" + " /n");
        response.sendRedirect("calendar.jsp?message=You don't have permissions to view that page.");
        return;
    }

    if (listofclasses.size() <= 0) {
        response.sendRedirect("calendar.jsp?message=Sorry,there are no classes in system.");
        return;
    }

    //to remove a student from section
    if (removeStudentId != null) {
        removeStudentId = Validation.prepare(removeStudentId);
        if (!(Validation.checkBuId(removeStudentId))) {
            message = Validation.getErrMsg();
        } else {
            ArrayList<ArrayList<String>> tempInfo = new ArrayList<ArrayList<String>>();
            if (!section.removeStudent(removeStudentId, c_id, sc_id,sc_semesterid)) {
                message = lecture.getErrMsg("AS11");
                elog.writeLog("[class_settings:] " + message + " /n");
                response.sendRedirect("logout.jsp?message=" + message);
                return;
            } else {
                successMessage = removeStudentId + " was removed from student list";
                response.sendRedirect("class_settings.jsp?class=" + selectedclass + "&successMessage=" + successMessage);
            }
        }
    }
    %>
    <script type='text/javascript'>
        /* CLASS SELECT BOX */
        $(function(){
            $('select').selectmenu({
                change: function (e, object) {
                    window.location.href = "class_settings.jsp?class="+object.value;
                }
            })
        });

        $(screen).ready(function() {
            /* Student List Table */
            $('#studentListTable').dataTable({
                "sPaginationType": "full_numbers",
                "aoColumnDefs": [{ "bSortable": false, "aTargets":[3]}], 
                "bRetrieve": true, 
                "bDestroy": true
            });
            
            $.fn.dataTableExt.sErrMode = 'throw';
            
            $('.dataTables_filter input').attr("placeholder", "Filter entries");
            
            $(".remove").click(function(){
                return window.confirm("Remove this student from list?");
            });
            
            $('#uploadFile').on('submit', function(e) {
                $.noty.closeAll();
                if (!(validateFile() && validateClass())) {
                    e.preventDefault();
                }
            });
            
            $('#addStudent').on('submit', function(e) {
                $.noty.closeAll();
                if (!validateClass()) {
                    e.preventDefault();
                }
            });
           
        });
        
        function validateClass() {
            var classToAdd =$('#classSel').val();
            if (classToAdd == null) {
                $('.warningMessage').text('Please choose a class to add student!');
                var notyMsg = noty({text: '<div>'+ $(".warningMessage").text()+' <img  class="notyCloseButton" src="${pageContext.servletContext.contextPath}/${initParam.CSSDirectory}/themes/base/images/x.png" alt="close" /></div>',
                                 layout: 'top',
                                 type: 'error'});
                return false;
            }
            return true;
        }
        
        function validateFile() {
            var filename = $('#studentListFile').val();
            if (filename.length < 1) {
                $('.warningMessage').text('Please choose a file to upload!');
                var notyMsg = noty({text: '<div>'+ $(".warningMessage").text()+' <img  class="notyCloseButton" src="${pageContext.servletContext.contextPath}/${initParam.CSSDirectory}/themes/base/images/x.png" alt="close" /></div>',
                                  layout: 'top',
                                  type: 'error'});
                return false;
            }
            return true;
        }
        
        /* Select Box */
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
                <p>
                    <a href="calendar.jsp" tabindex="13">home</a> � 
                    <a href="class_settings.jsp" tabindex="14">class settings</a>
                </p>
                <!-- PAGE NAME -->
                <h1 style="margin-bottom:20px">Class Settings</h1>
                <!-- MESSAGES -->
                <div class="warningMessage"><%=message %></div>
                <div class="successMessage"><%=successMessage %></div>
            </header>
            <% if (listofclasses.size() > 0) { %>
            <form id="uploadFile" action="uploadfile.jsp" method="post" enctype="multipart/form-data" >
                <article>
                    <div class="content">
                        <fieldset>
                            <div class="component">
                                <label for="classSel" class="label">Class:</label>
                                <select name="class" id="classSel" title="Class select box. Use the alt key in combination 
                                                with the arrow keys to select an option." tabindex="1" role="listbox" style="width: 402px">
                                    <option role='option' selected disabled>Choose a class</option>
                                    <%
                                    for (int j=0; j < listofclasses.size(); ++j) {
                                        String fullclass = listofclasses.get(j).get("c_id") + "-" + listofclasses.get(j).get("sc_id")+ "-" + listofclasses.get(j).get("sc_semesterid") + "-" + listofclasses.get(j).get("bu_id");
                                        out.println("<option role='option' " + (fullclass.equals(selectedclass)?"selected":"") +">" + fullclass + "</option>");
                                    }
                                    %>
                                </select>
                            </div>
            <% }%>
                        </fieldset>
                        <fieldset>
                            <div class="component">
                                <label for="loadFile" class="label">Add Students From File:</label>
                                <input type="file" name="studentListFile" id="studentListFile" >
                                <button type="submit" name="submitFile" id="submitFile" class="button" title="Click here to add Student"  >Load File</button>
                            </div>
                        </fieldset>
                    </div>
                </article>
            </form>
            <form id="addStudent" name="addStudent" method="get" action="persist_class_settings.jsp" >
                <article>
                    <header>
                        <h2>Add Student</h2>
                        <img class="expandContent" width="9" height="6" src="${pageContext.servletContext.contextPath}/${initParam.ImagesDirectory}/arrowDown.svg" title="Click here to collapse/expand content" alt="Arrow"/>
                    </header>
                    <div class="content">
                        <fieldset>
                            <div class="component">
                                <label for="searchBoxAddStudent" class="label">Search Student to Add:</label>
                                <input type="hidden" name="classSectionInfo" id="classSectionInfo" value="<%= selectedclass %>" >
                                <input type="text" name="searchBox" id="searchBox" class="searchBox" tabindex="37" title="Search user">
                                <button type="submit" name="search" class="search" tabindex="38" title="Search user"></button>
                                <div id="responseDiv"></div>
                            </div>
                        </fieldset>
                    </div>
                </article>
                <article>
                    <header id="expandGuest">
                        <h2>Student List</h2>
                        <img class="expandContent" width="9" height="6" src="${pageContext.servletContext.contextPath}/${initParam.ImagesDirectory}/arrowDown.svg" title="Click here to collapse/expand content"/>
                    </header>
                    <div class="content">
                        <fieldset>
                            <div id="currentEventDiv" class="tableComponent">
                                <table id="studentListTable" border="0" cellpadding="0" cellspacing="0">
                                    <thead>
                                        <tr>
                                            <th class="firstColumn" tabindex="16">Id<span></span></th>
                                            <th>Nick Name<span></span></th>
                                            <th>Banned<span></span></th>
                                            <th width="65" title="Remove" class="icons" align="center">Remove</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <%  if(stuList.size()<1){ %>
                                        <tr>
                                            <td class="row">No Students in this section</td>
                                            <td></td>
                                            <td></td>
                                            <td></td>
                                        </tr>
                                        <%}else 
                                        for(int k=0;k<stuList.size();k++){%>
                                        <tr>
                                            <td class="row"><%= stuList.get(k).get("bu_id")%></td>
                                            <td><% if(user.getNickName(nickNameResult, stuList.get(k).get("bu_id"))) out.print(nickNameResult.get(0).get("bu_nick")); %></td>
                                            <td><%= stuList.get(k).get("s_isbanned")%></td>
                                            <td class="icons" align="center">
                                            <a onclick="savePageOffset()" href="<%= "class_settings.jsp?class="+ selectedclass + "&removeStudent=" + stuList.get(k).get("bu_id") %>" class="remove">
                                                <img src="${pageContext.servletContext.contextPath}/${initParam.ImagesDirectory}/iconPlaceholder.svg" width="17" height="17" title="Remove user" alt="Remove"/>
                                            </a>
                                            </td>
                                        </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                        </fieldset>
                    </div>
                </article>
                <br /><hr /><br />
            </form>
        </section>
        <jsp:include page="footer.jsp"/>
    </div>
</body>
</html>