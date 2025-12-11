<%-- 
    Document   : home
    Created on : Jan 14, 2024, 9:34:13 PM
    Author     : songk
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Mobile Card</title>
        <%@include file="../components/libs.jsp" %>
    </head>
    <body>
        <div class="">
            <%@include file="../components/header.jsp" %>
        </div>
        <div class="d-block container" style="min-height: 100vh">
            <div class="container align-items-start justify-content-center d-flex bg-light" >
                <c:set var="sliders" value="${requestScope.sliders}" />
                <section class="w-75 bg-body">
                    <%@include file="../components/sliders.jsp" %>
                </section>

            </div>
                
            <section>
                <%--<c:set var="user" value="1"/>--%>
                <c:set var="courselists" value="${requestScope.featuredcourses}" />
                <%@include file="../components/courses.jsp" %>
            </section>
            <section>
                <c:set var="postlist" value="${requestScope.hotposts}" />
                <%@include file="../components/posts.jsp" %>
            </section>


        </div>


        <%@include file="../components/footer.jsp"%>


    </body>
</html>
