
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<div class="dropdown-menu" aria-labelledby="adminDropdown">
    <a class="dropdown-item" href="${pageContext.request.contextPath}/admin/dashboard">
        <i class="bi bi-speedometer2 me-2"></i>Dashboard
    </a>
    <a class="dropdown-item" href="${pageContext.request.contextPath}/admin/users">
        <i class="bi bi-people me-2"></i>User list
    </a>
    <a class="dropdown-item" href="${pageContext.request.contextPath}/plist">
        <i class="bi bi-box me-2"></i>Product list
    </a>
    <a class="dropdown-item" href="${pageContext.request.contextPath}/provider-import">
        <i class="bi bi-truck me-2"></i>Nhập hàng từ NCC
    </a>
    <a class="dropdown-item" href="${pageContext.request.contextPath}/pklist">
        <i class="bi bi-archive me-2"></i>Storage list
    </a>
    <div role="separator" class="dropdown-divider"></div>
    <a class="dropdown-item" href="${pageContext.request.contextPath}/vlist">
        <i class="bi bi-ticket-perforated me-2"></i>Voucher list
    </a>
    <a class="dropdown-item" href="${pageContext.request.contextPath}/sliderslist">
        <i class="bi bi-cart me-2"></i>Order list
    </a>
    <a class="dropdown-item" href="${pageContext.request.contextPath}/registrationslist">
        <i class="bi bi-wallet2 me-2"></i>Transactions list
    </a>
</div>
