

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <%@include file="../components/libs.jsp" %>
    </head>
    <body>
        <%@include file="../components/header.jsp" %>
        
        <div class="container " style="height:  50vh;">
            <h6 class="text-center mt-5">${requestScope.msg}</h6>
        </div>
        <%@include file="../components/footer.jsp" %>

    </body>
</html>
