

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<div class="dropdown-menu" aria-labelledby="adminDropdown">
    <a class="dropdown-item" href="${pageContext.request.contextPath}/admin/dashboard">
        <i class="bi bi-speedometer2 me-2"></i>Dashboard
    </a>
    <a class="dropdown-item" href="${pageContext.request.contextPath}/admin/reports">
        <i class="bi bi-graph-up me-2"></i>Reports
    </a>
    <a class="dropdown-item" href="${pageContext.request.contextPath}/admin/users">
        <i class="bi bi-people me-2"></i>User list
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
    <a class="dropdown-item" href="${pageContext.request.contextPath}/admin/transactions">
        <i class="bi bi-wallet2 me-2"></i>Transactions list
    </a>
</div>
<body>
    <div></div>

    <a class="dropdown-item" href="ulist">User list</a>

    <a class="dropdown-item" href="pklist">Storage list</a>
    <div role="separator" class="dropdown-divider"></div>
<li class="dropdown-item"><a href="sliderslist">Order list</a></li>
<li class="dropdown-item"><a href="${pageContext.request.contextPath}/admin/transactions">Transactions list</a></li>
<li class="dropdown-item"><a href="${pageContext.request.contextPath}/admin/feedback">Feedback list</a></li>

</body>
</html>

