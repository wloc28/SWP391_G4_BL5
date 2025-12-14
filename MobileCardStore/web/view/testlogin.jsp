<%-- 
    Document   : testlogin
    Created on : 11 thg 12, 2025, 23:49:20
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Customer Dashboard</title>
        <%@include file="../components/libs.jsp" %>
    </head>
    <body>
        <%@include file="../components/header.jsp" %>
        
        <div class="container mt-5">
            <c:if test="${sessionScope.user == null}">
                <div class="alert alert-warning">
                    <h4>Bạn chưa đăng nhập!</h4>
                    <a href="${pageContext.request.contextPath}/view/login.jsp" class="btn btn-primary">Đăng nhập ngay</a>
                </div>
            </c:if>
            
            <c:if test="${sessionScope.user != null}">
                <c:if test="${sessionScope.role == 'ADMIN'}">
                    <div class="alert alert-danger">
                        <h4>Bạn đang đăng nhập với quyền ADMIN!</h4>
                        <p>Trang này chỉ dành cho CUSTOMER. Vui lòng đăng nhập với tài khoản CUSTOMER.</p>
                        <a href="${pageContext.request.contextPath}/index_1.html" class="btn btn-primary">Về trang Admin</a>
                    </div>
                </c:if>
                
                <c:if test="${sessionScope.role == 'CUSTOMER' || sessionScope.role == null}">
                    <div class="card">
                        <div class="card-header bg-primary text-white">
                            <h2 class="mb-0">Đăng nhập thành công - Customer Dashboard</h2>
                        </div>
                        <div class="card-body">
                            <h4>Thông tin tài khoản:</h4>
                            <ul class="list-group">
                                <li class="list-group-item"><strong>User ID:</strong> ${sessionScope.userId}</li>
                                <li class="list-group-item"><strong>Username:</strong> ${sessionScope.username}</li>
                                <li class="list-group-item"><strong>Email:</strong> ${sessionScope.email}</li>
                                <li class="list-group-item"><strong>Full Name:</strong> ${sessionScope.user.fullName}</li>
                                <li class="list-group-item"><strong>Phone:</strong> ${sessionScope.user.phoneNumber}</li>
                                <li class="list-group-item"><strong>Role:</strong> ${sessionScope.role}</li>
                                <li class="list-group-item"><strong>Balance:</strong> ${sessionScope.user.balance}</li>
                            </ul>
                            
                            <div class="mt-4">
                                <a href="${pageContext.request.contextPath}/logout" class="btn btn-secondary">Đăng xuất</a>
                            </div>
                        </div>
                    </div>
                </c:if>
            </c:if>
        </div>
        
        <%@include file="../components/footer.jsp" %>
    </body>
</html>
