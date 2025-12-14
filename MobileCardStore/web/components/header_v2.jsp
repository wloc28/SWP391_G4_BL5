<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%--
    header_v2.jsp - Updated header for Mobile Card Store
    Changes from original header.jsp:
    1. Uses String role comparison ('ADMIN', 'CUSTOMER') instead of integer (1, 2)
    2. Added wallet balance display for logged-in users
    3. Updated navigation links for card store (removed course/post links)
    TODO for team:  Migrate all pages to use this header after login system is updated
--%>

<!-- Customer Header (role = CUSTOMER or not logged in) -->
<c:if test="${sessionScope.info.role == 'CUSTOMER' or sessionScope.info == null}">
    <header class="p-3 bg-dark text-white">
    <div class="container">
    <div class="d-flex flex-wrap justify-content-between align-items-center">

    <ul class="nav mb-2 justify-content-center mb-md-0">
    <li><a href="home" class="nav-link px-2 text-white fw-bold">Mobile Card Store</a></li>
    <li><a href="products" class="nav-link px-2 text-secondary">Sản phẩm</a></li>
    </ul>

    <!-- Not logged in:  Show Login/Register buttons -->
    <c:if test="${sessionScope.info == null}">
        <div class="text-end">
            <!-- Login Button -->
            <button type="button" class="btn btn-outline-light me-2" data-bs-toggle="modal" data-bs-target="#popupLogin">
                Đăng nhập
            </button>
            <c:if test="${requestScope.page != 1}">
                <div class="modal fade" id="popupLogin" tabindex="-1" aria-labelledby="popupLoginLabel" aria-hidden="true">
                    <div class="modal-dialog">
                        <div class="modal-content" style="background-color: #e9ecef">
                            <div class="modal-header">
                                <h2>Đăng nhập</h2>
                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                            </div>
                            <div class="modal-body">
                                <%@include file="loginForm.jsp" %>
                            </div>
                        </div>
                    </div>
                </div>
            </c:if>

            <!-- Register Button -->
            <button type="button" class="btn btn-warning" data-bs-toggle="modal" data-bs-target="#popupRegister">
                Đăng ký
            </button>
            <c:if test="${requestScope.page != 1}">
                <div class="modal fade" id="popupRegister" tabindex="-1" aria-labelledby="popupRegisterLabel" aria-hidden="true">
                    <div class="modal-dialog">
                        <div class="modal-content" style="background-color: #e9ecef">
                            <div class="modal-header">
                                <h2>Đăng ký</h2>
                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                            </div>
                            <div class="modal-body">
                                <%@include file="registerForm.jsp" %>
                            </div>
                        </div>
                    </div>
                </div>
            </c:if>
        </div>
        </c:if>

        <!-- Logged-in Customer: Show wallet + dropdown -->
        <c:if test="${sessionScope.info != null}">
            <div class="d-flex align-items-center">
                <!-- Wallet Balance -->
                <span class="text-warning me-3">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-wallet2 me-1" viewBox="0 0 16 16">
                            <path d="M12. 136. 326A1.5 1.5 0 0 1 14 1.78V3h. 5A1.5 1.5 0 0 1 16 4.5v9a1.5 1.5 0 0 1-1.5 1.5h-13A1.5 1.5 0 0 1 0 13.5v-9a1.5 1.5 0 0 1 1.432-1.499L12.136.326zM5.562 3H13V1.78a. 5.5 0 0 0-. 621-. 484L5.562 3zM1.5 4a. 5.5 0 0 0-. 5.5v9a. 5.5 0 0 0 .5.5h13a.5.5 0 0 0 .5-.5v-9a.5.5 0 0 0-.5-.5h-13z"/>
                        </svg>
                        Số dư: <strong><fmt:formatNumber value="${sessionScope.info.balance}" type="number" maxFractionDigits="0"/> đ</strong>
                    </span>

                <!-- User Dropdown -->
                <div class="dropdown">
                    <button class="btn btn-outline-light dropdown-toggle" type="button" id="userDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                            ${sessionScope.info.fullName != null ? sessionScope.info.fullName : sessionScope.info. sername}
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="userDropdown">
                        <li><a class="dropdown-item" href="profile">Thông tin cá nhân</a></li>
                        <li><a class="dropdown-item" href="order-history">Lịch sử đơn hàng</a></li>
                        <li><a class="dropdown-item" href="wallet">Nạp tiền</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item text-danger" href="logout">Đăng xuất</a></li>
                    </ul>
                </div>
            </div>
        </c:if>

        </div>
        </div>
        </header>
    </c:if>
    <!-- Admin Header (role = ADMIN) -->
    <c:if test="${sessionScope.info.role == 'ADMIN'}">
        <header class="p-3 text-white" style="background-color: #51585e">
        <div class="container">
        <div class="d-flex flex-wrap justify-content-between align-items-center">

        <ul class="nav mb-2 justify-content-center mb-md-0">
        <li><a href="home" class="nav-link px-2 text-primary fw-bold">Mobile Card Store</a></li>
        <li><a href="ulist" class="nav-link px-2 text-white">Quản lý User</a></li>
        <li><a href="plist" class="nav-link px-2 text-white">Quản lý Sản phẩm</a></li>
        <li><a href="pklist" class="nav-link px-2 text-white">Quản lý Kho</a></li>
        <li><a href="orders-manage" class="nav-link px-2 text-white">Quản lý Đơn hàng</a></li>
        <li><a href="transactions-manage" class="nav-link px-2 text-white">Giao dịch</a></li>
        </ul>

        <c:if test="${sessionScope.info != null}">
            <div class="d-flex align-items-center">
                <!-- Admin Badge -->
                <span class="badge bg-danger me-3">ADMIN</span>

                <!-- User Dropdown -->
                <div class="dropdown">
                    <button class="btn btn-outline-light dropdown-toggle" type="button" id="adminDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                            ${sessionScope.info.fullName != null ? sessionScope.info.fullName : sessionScope.info.username}
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="adminDropdown">
                        <li><a class="dropdown-item" href="profile">Thông tin cá nhân</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item text-danger" href="logout">Đăng xuất</a></li>
                    </ul>
                </div>
            </div>
            </c:if>

            </div>
            </div>
            </header>
        </c:if>