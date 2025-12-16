
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Login</title>
        <%@include file="../components/libs.jsp" %>
    </head>
    <body>
        <%@include file="../components/header.jsp" %>
        
        <div class="container mt-5">
            <div class="row justify-content-center">
                <div class="col-md-4">
                    <h2 class="text-center mb-4">Đăng Nhập</h2>
                    
                    <c:if test="${not empty param.success}">
                        <div class="alert alert-success" role="alert">
                            ${param.success}
                        </div>
                    </c:if>
                    
                    <form action="login" method="post">
                        <div class="mb-3">
                            <label for="email" class="form-label">Email</label>
                            <input type="email" name="user" class="form-control" id="email" value="${requestScope.userEmail}" placeholder="Nhập email" required>
                        </div>
                        
                        <div class="mb-3">
                            <label for="password" class="form-label">Mật khẩu</label>
                            <input type="password" name="pass" class="form-control" id="password" placeholder="Nhập mật khẩu" required>
                            <c:if test="${not empty requestScope.passmsg}">
                                <div class="text-danger mt-2">${requestScope.passmsg}</div>
                            </c:if>
                        </div>
                        
                        <div class="d-grid mb-3">
                            <button type="submit" class="btn btn-primary">Đăng Nhập</button>
                        </div>
                        
                        <div class="text-center">
                            <p class="mb-1">Chưa có tài khoản? <a href="${pageContext.request.contextPath}/register">Đăng ký ngay</a></p>
                            <p><a href="forgotpassword">Quên mật khẩu?</a></p>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <%@include file="../components/footer.jsp" %>
    </body>
</html>
