<!doctype html>
<html lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html" charset="utf-8" />
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Seneca | Conference Management System</title>
<link rel="shortcut icon" href="http://www.cssreset.com/favicon.png" />
<!--<link href="css/style.css" rel="stylesheet" type="text/css" media="screen and (min-width:1280px)">-->
<link href="css/style.css" rel="stylesheet" type="text/css" media="all">
<link href="css/fonts.css" rel="stylesheet" type="text/css" media="all">
<script type="text/javascript" src="http://code.jquery.com/jquery-1.9.1.js"></script>
<script type="text/javascript" src="js/modernizr.custom.79639.js"></script>
<script type="text/javascript" src="js/component.js"></script>
<script type="text/javascript" src="js/componentStepper.js"></script>

<% 
	String message = request.getParameter("message");
	if (message == null || message == "null") {
		message="";
	}
%>
	
</head>
<body>
<div id="page">
	<jsp:include page="header.jsp"/>
	<jsp:include page="menu.jsp"/>
	<section>
	 <header>
      <p><a href="calendar.jsp" tabindex="13">home</a> � <a href="settings.jsp" tabindex="14">settings</a> � change password</p>
      <h1>Change Password</h1><%=message%>
    </header>
    <form action="persist_password.jsp" method="get">
		<article>
		<header>
		    <h2>Edit Password</h2>
		    <img class="expandContent" width="9" height="6" src="images/arrowDown.svg" title="Click here to collapse/expand content"/></header>
		  <fieldset>
		    <div class="component">
		      <label for="currentPassword" class="label">Current password:</label>
		      <input type="password" name="currentPassword" id="currentPassword" class="input" tabindex="19" title="Current password">
		    </div>
		    <div class="component">
		      <label for="newPassword" class="label">New password:</label>
		      <input type="password" name="newPassword" id="newPassword" class="input" tabindex="20" title="New password">
		    </div>
		    <div class="component">
		      <label for="confirmPassword" class="label">Confirm password:</label>
		      <input type="password" name="confirmPassword" id="confirmPassword" class="input" tabindex="21" title="Confirm password">
		    </div>
		  </fieldset>
		</article>
		 <article>
        <fieldset>
          <div class="buttons">
            <button type="submit" name="submit" id="save" class="button" title="Click here to save inserted data">Save</button>
            <button type="button" name="button" id="cancel"  class="button" title="Click here to cancel">Cancel</button>
          </div>
        </fieldset>
      </article>
		</form>
	</section>
	<jsp:include page="footer.jsp"/>
</div>
</body>
</html>
