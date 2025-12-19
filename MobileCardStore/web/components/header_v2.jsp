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
<c:if test="${sessionScope.info == null or (sessionScope.info != null and sessionScope.info.role == 'CUSTOMER')}">
    <header class="p-3 bg-dark text-white">
    <div class="container">
    <div class="d-flex flex-wrap justify-content-between align-items-center">

    <ul class="nav mb-2 justify-content-center mb-md-0">
    <li><a href="home" class="nav-link px-2 text-white fw-bold">Mobile Card Store</a></li>
    <li><a href="products" class="nav-link px-2 text-secondary">Sản phẩm</a></li>
    </ul>

    <!-- Not logged in:  Show Login/Register buttons -->
    <c:if test="${sessionScope.info == null and sessionScope.user == null}">
        <div class="text-end">
            <!-- Login Button -->
            <a href="${pageContext.request.contextPath}/login" class="btn btn-outline-light me-2">
                Đăng nhập
            </a>
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
            <a href="${pageContext.request.contextPath}/register" class="btn btn-warning">
                Đăng ký
            </a>
        </div>
        </c:if>

        <!-- Logged-in Customer: Show wallet + dropdown -->
        <c:if test="${sessionScope.info != null or sessionScope.user != null}">
            <div class="d-flex align-items-center">  
                <!-- Wallet Balance -->
                <span class="text-warning me-3">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-wallet2 me-1" viewBox="0 0 16 16">
                            <path d="M12. 136. 326A1.5 1.5 0 0 1 14 1.78V3h. 5A1.5 1.5 0 0 1 16 4.5v9a1.5 1.5 0 0 1-1.5 1.5h-13A1.5 1.5 0 0 1 0 13.5v-9a1.5 1.5 0 0 1 1.432-1.499L12.136.326zM5.562 3H13V1.78a. 5.5 0 0 0-. 621-. 484L5.562 3zM1.5 4a. 5.5 0 0 0-. 5.5v9a. 5.5 0 0 0 .5.5h13a.5.5 0 0 0 .5-.5v-9a.5.5 0 0 0-.5-.5h-13z"/>
                        </svg>
                        Số dư: <strong>
                            <c:choose>
                                <c:when test="${sessionScope.info != null and sessionScope.info.balance != null}">
                                    <fmt:formatNumber value="${sessionScope.info.balance}" type="number" maxFractionDigits="0"/> đ
                                </c:when>
                                <c:when test="${sessionScope.user != null and sessionScope.user.balance != null}">
                                    <fmt:formatNumber value="${sessionScope.user.balance}" type="number" maxFractionDigits="0"/> đ
                                </c:when>
                                <c:otherwise>0 đ</c:otherwise>
                            </c:choose>
                        </strong>
                    </span>
                
                <!-- Cart Button with Badge -->
                <%
                    try {
                        Models.User currentUser = (Models.User)session.getAttribute("info");
                        if (currentUser == null) {
                            currentUser = (Models.User)session.getAttribute("user");
                        }
                        
                        int cartItemCount = 0;
                        if (currentUser != null) {
                            DAO.user.CartDAO cartDAO = new DAO.user.CartDAO();
                            cartItemCount = cartDAO.getCartItemCountByUserId(currentUser.getUserId());
                        }
                        pageContext.setAttribute("cartItemCount", cartItemCount);
                    } catch (Exception e) {
                        pageContext.setAttribute("cartItemCount", 0);
                    }
                %>
                <a href="${pageContext.request.contextPath}/cart" class="btn btn-outline-light position-relative me-3">
                    <i class="bi bi-cart"></i> Giỏ hàng
                    <c:if test="${cartItemCount > 0}">
                        <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger">
                            ${cartItemCount}
                        </span>
                    </c:if>
                </a>

                <!-- User Dropdown -->
                <div class="dropdown">
                    <%
                        // Map avatar codes với URLs for customer
                        java.util.Map<String, String> customerAvatarMap = new java.util.HashMap<>();
                        customerAvatarMap.put("image1", "https://linhkien283.com/wp-content/uploads/2025/10/Hinh-anh-avatar-vo-tri-cute-1.jpg");
                        customerAvatarMap.put("image2", "https://linhkien283.com/wp-content/uploads/2025/10/Hinh-anh-avatar-vo-tri-cute-2.jpg");
                        customerAvatarMap.put("image3", "https://linhkien283.com/wp-content/uploads/2025/10/Hinh-anh-avatar-vo-tri-cute-6.jpg");
                        String customerDefaultAvatar = customerAvatarMap.get("image2");
                        
                        // Lấy user từ session (có thể là "info" hoặc "user")
                        Models.User customerUser = (Models.User)session.getAttribute("info");
                        if (customerUser == null) {
                            customerUser = (Models.User)session.getAttribute("user");
                        }
                        
                        String customerAvatarUrl = customerDefaultAvatar;
                        if (customerUser != null && customerUser.getImage() != null && !customerUser.getImage().trim().isEmpty()) {
                            customerAvatarUrl = customerAvatarMap.getOrDefault(customerUser.getImage().trim(), customerDefaultAvatar);
                        }
                        pageContext.setAttribute("customerAvatarUrl", customerAvatarUrl);
                        pageContext.setAttribute("customerDefaultAvatar", customerDefaultAvatar);
                    %>
                    <button class="btn btn-outline-light dropdown-toggle d-flex align-items-center" type="button" id="userDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                        <img src="${customerAvatarUrl}" 
                             alt="Avatar" 
                             class="rounded-circle me-2" 
                             style="width: 32px; height: 32px; object-fit: cover; border: 2px solid rgba(255,255,255,0.3);"
                             onerror="this.src='${customerDefaultAvatar}'">
                        <span>${sessionScope.info.fullName != null && !empty sessionScope.info.fullName ? sessionScope.info.fullName : sessionScope.info.username}</span>
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="userDropdown">
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/viewProfile"><i class="bi bi-person me-2"></i>Thông tin cá nhân</a></li>
                        <li><a class="dropdown-item" href="order-history"><i class="bi bi-clock-history me-2"></i>Lịch sử đơn hàng</a></li>
                        <li><a class="dropdown-item" href="wallet"><i class="bi bi-wallet2 me-2"></i>Nạp tiền</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout"><i class="bi bi-box-arrow-right me-2"></i>Đăng xuất</a></li>
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
        <header class="p-3 text-white" style="background-color: #343a40">
        <div class="container">
        <div class="d-flex flex-wrap justify-content-between align-items-center">

        <ul class="nav mb-2 justify-content-center mb-md-0">
        <li><a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-link px-2 text-white fw-bold">Mobile Card Store</a></li>
        </ul>

        <c:if test="${sessionScope.info != null or sessionScope.user != null}">
            <%
                // Map avatar codes với URLs
                java.util.Map<String, String> avatarMap = new java.util.HashMap<>();
                avatarMap.put("image1", "https://linhkien283.com/wp-content/uploads/2025/10/Hinh-anh-avatar-vo-tri-cute-1.jpg");
                avatarMap.put("image2", "https://linhkien283.com/wp-content/uploads/2025/10/Hinh-anh-avatar-vo-tri-cute-2.jpg");
                avatarMap.put("image3", "https://linhkien283.com/wp-content/uploads/2025/10/Hinh-anh-avatar-vo-tri-cute-6.jpg");
                String defaultAvatar = avatarMap.get("image2");
                
                // Lấy user từ session (có thể là "info" hoặc "user")
                Models.User adminUser = (Models.User)session.getAttribute("info");
                if (adminUser == null) {
                    adminUser = (Models.User)session.getAttribute("user");
                }
                
                String avatarUrl = defaultAvatar;
                if (adminUser != null && adminUser.getImage() != null && !adminUser.getImage().trim().isEmpty()) {
                    avatarUrl = avatarMap.getOrDefault(adminUser.getImage().trim(), defaultAvatar);
                }
                pageContext.setAttribute("avatarUrl", avatarUrl);
                pageContext.setAttribute("defaultAvatar", defaultAvatar);
            %>
           

                <!-- User Dropdown with Avatar -->
                <div class="dropdown">
                    <button class="btn btn-outline-light dropdown-toggle d-flex align-items-center" type="button" id="adminDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                        <img src="${avatarUrl}" 
                             alt="Avatar" 
                             class="rounded-circle me-2" 
                             style="width: 32px; height: 32px; object-fit: cover; border: 2px solid rgba(255,255,255,0.3);"
                             onerror="this.src='${defaultAvatar}'">
                        <span>${sessionScope.info.fullName != null && !empty sessionScope.info.fullName ? sessionScope.info.fullName : sessionScope.info.username}</span>
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="adminDropdown">
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/viewProfile"><i class="bi bi-person me-2"></i>Thông tin cá nhân</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/dashboard"><i class="bi bi-speedometer2 me-2"></i>Dashboard</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/users"><i class="bi bi-people me-2"></i>User list</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/plist"><i class="bi bi-box me-2"></i>Product list</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/provider-import"><i class="bi bi-truck me-2"></i>Nhập hàng từ NCC</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/pklist"><i class="bi bi-archive me-2"></i>Storage list</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/vlist"><i class="bi bi-ticket-perforated me-2"></i>Voucher list</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/sliderslist"><i class="bi bi-cart me-2"></i>Order list</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/registrationslist"><i class="bi bi-wallet2 me-2"></i>Transactions list</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout"><i class="bi bi-box-arrow-right me-2"></i>Đăng xuất</a></li>
                    </ul>
                </div>
            </div>
            </c:if>

            </div>
            </div>
            </header>
        </c:if>
