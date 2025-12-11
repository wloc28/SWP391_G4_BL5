
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>

    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link href="CSS/styleindex.css" rel=”stylesheet”/>
        <title>Login</title>
        <%@include file="../components/libs.jsp" %>

    </head>
    <body >
        <%@include file="../components/header.jsp" %>
        <h2 class="mt-5 text-center">Login</h2>
        <%@include file="../components/loginForm.jsp" %>

        <%@include file="../components/footer.jsp" %>

    </body>
</html>
