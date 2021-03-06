<%@page import="db.DBConnection"%>
<%@page import="hash.PasswordHash"%>
<%@page import="sql.User"%>
<%@page import="java.util.*"%>
<%@page import= "helper.*" %>
<jsp:useBean id="ldap" class="ldap.LDAPAuthenticate" scope="session" />
<jsp:useBean id="hash" class="hash.PasswordHash" scope="session" />
<jsp:useBean id="dbaccess" class="db.DBAccess" scope="session" />
<jsp:useBean id="usersession" class="helper.UserSession" scope="session" />

<%@ page language="java" import="java.sql.*" errorPage=""%>
<%
//Start page validation
String userId = usersession.getUserId();
GetExceptionLog elog = new GetExceptionLog();
if (userId.equals("")) {
    session.setAttribute("redirecturl",request.getRequestURI() + (request.getQueryString() != null ? "?" + request.getQueryString() : ""));
    response.sendRedirect("index.jsp?message=Please log in");
    return;
}
if (dbaccess.getFlagStatus() == false) {
    elog.writeLog("[persist_user_settings:] " + "database connection error /n");
    response.sendRedirect("index.jsp?message=Database connection error");
    return;
} //End page validation

String message = "";
HashMap<String, Integer> map = new HashMap<String, Integer>();
User user = new User(dbaccess);
ArrayList<HashMap<String, String>> roleInfoResult = new ArrayList<HashMap<String, String>>();
String nickname = request.getParameter("nickname");
if (nickname == null) {
    nickname = "";
}
user.getRoleInfo(roleInfoResult, userId);
Boolean flag = false;
if (usersession.isSuper() || usersession.isProfessor() || usersession.isDepartmentAdmin() || roleInfoResult.get(0).get("pr_name").equals("employee")) {
    flag = true;
}
if (flag) {
    user.setNickName(userId, nickname);
    usersession.setNick(nickname);
}
//Language selector
map.put(Settings.bu_setting[2], 1);

String setting1box = request.getParameter("setting1box");
if (setting1box == null) {
    map.put(Settings.bu_setting[1], 0);
} else {
    map.put(Settings.bu_setting[1], 1);
}

String setting2box = request.getParameter("setting2box");
if (setting2box == null) {
    map.put(Settings.bu_setting[0], 0);
} else {
    map.put(Settings.bu_setting[0], 1);
}

if (!user.setUserSetting(map, usersession.getUserId())) {
    response.sendRedirect("settings.jsp?message=Failed to save user settings");
    return;
} else {
    usersession.setUserSettingsMask(map);
}

map.clear();

String eventSetting1box = request.getParameter("eventSetting1box");
if (eventSetting1box == null) {
    map.put(Settings.meeting_setting[2], 0);
} else {
    map.put(Settings.meeting_setting[2], 1);
}

String eventSetting2box = request.getParameter("eventSetting2box");
if (eventSetting2box == null) {
    map.put(Settings.meeting_setting[3], 0);
} else {
    map.put(Settings.meeting_setting[3], 1);
}

String eventSetting3box = request.getParameter("eventSetting3box");
if (eventSetting3box == null) {
    map.put(Settings.meeting_setting[1], 0);
} else {
    map.put(Settings.meeting_setting[1], 1);
}

String eventSetting4box = request.getParameter("eventSetting4box");
if (eventSetting4box == null) {
    map.put(Settings.meeting_setting[0], 0);
} else {
    map.put(Settings.meeting_setting[0], 1);
}

//Layout
map.put(Settings.meeting_setting[4], 0);

if (!user.setUserMeetingSetting(map, usersession.getUserId())) {
    response.sendRedirect("settings.jsp?message=Failed to save meeting settings");
    return;
} else {
    usersession.setUserMeetingSettingsMask(map);
}
response.sendRedirect("settings.jsp?successMessage=Saved settings successfully");
%>