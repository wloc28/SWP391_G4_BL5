<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<! DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Trang Chủ - Mobile Card Store</title>
    <%@include file="../components/libs.jsp" %>
    <style>
        /* Hero Section */
        .hero-section {
            background:  linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
            color: white;
            padding: 60px 0;
            margin-bottom: 40px;
        }

        .hero-section h1 {
            font-size:  2.5rem;
            font-weight: 700;
            margin-bottom: 15px;
        }

        .hero-section p {
            font-size: 1.2rem;
            opacity: 0.9;
        }

        /* Provider Cards */
        .provider-card {
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            cursor: pointer;
            border: 1px solid #dee2e6;
        }

        .provider-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.15);
        }

        .provider-card.card-body {
            text-align: center;
            padding: 20px;
        }

        .provider-icon {
            width:  60px;
            height: 60px;
            object-fit: contain;
            margin-bottom: 10px;
        }

        .provider-icon-placeholder {
            width: 60px;
            height: 60px;
            background-color: #e9ecef;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 10px auto;
            font-size: 1.8rem;
            color: #495057;
        }

        .provider-icon-placeholder i {
            line-height: 1;
        }

        /* Product Cards */
        .product-card {
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            height: 100%;
        }

        .product-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 5px 20px rgba(0,0,0,0.12);
        }

        .product-card .card-img-top {
            height: 150px;
            object-fit: cover;
            background-color: #f8f9fa;
        }

        .product-card .card-body {
            display: flex;
            flex-direction: column;
        }

        .product-card.card-title {
            font-size: 1rem;
            font-weight: 600;
            margin-bottom: 8px;
        }

        .product-price {
            font-size: 1.25rem;
            font-weight: 700;
            color:  #212529;
        }

        .stock-badge {
            font-size: 0.8rem;
        }

        .out-of-stock {
            opacity: 0.6;
        }

        .out-of-stock.btn {
            pointer-events: none;
        }

        /* Section Styling */
        .section-title {
            font-size: 1.5rem;
            font-weight:  600;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #dee2e6;
        }

        .provider-section {
            margin-bottom: 50px;
        }

        .provider-section-header {
            display:  flex;
            align-items: center;
            margin-bottom: 20px;
        }

        .provider-section-header img {
            width:  40px;
            height: 40px;
            object-fit: contain;
            margin-right: 15px;
        }

        .provider-type-badge {
            font-size: 0.75rem;
            padding: 3px 8px;
            margin-left: 10px;
        }
    </style>
</head>
<body>
<%-- Using header_v2.jsp for new role system --%>
<%@include file="../components/header_v2.jsp" %>

<!-- Hero Section (Static Banner) -->
<section class="hero-section">
    <div class="container text-center">
        <h1>Mobile Card Store</h1>
        <p>Mua thẻ nhanh - Giá tốt nhất - Giao dịch an toàn</p>
        <div class="mt-4">
            <a href="products" class="btn btn-warning btn-lg me-2">
                Xem tất cả sản phẩm
            </a>
        </div>
    </div>
</section>

<div class="container" style="min-height: 60vh;">

    <!-- Error Message -->
    <c:if test="${not empty error}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                ${error}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <!-- Quick Navigation:  Provider Cards -->
    <section class="mb-5">
        <h2 class="section-title">Nhà Cung Cấp</h2>
        <div class="row g-3">
            <c:forEach var="provider" items="${providers}">
                <div class="col-6 col-md-4 col-lg-2">
                    <a href="products?providerId=${provider.providerId}" class="text-decoration-none">
                        <div class="card provider-card h-100">
                            <div class="card-body">
                                <c:choose>
                                    <c:when test="${not empty provider.imageUrl}">
                                        <img src="${provider.imageUrl}" alt="${provider.providerName}" class="provider-icon">
                                    </c:when>
                                    <c:otherwise>
                                        <div class="provider-icon-placeholder">
                                            <c:choose>
                                                <c:when test="${provider.providerType == 'TEL'}">
                                                    <i class="bi bi-phone" style="font-size: 2rem;"></i>
                                                </c:when>
                                                <c:otherwise>
                                                    <i class="bi bi-controller" style="font-size: 2rem;"></i>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                                <h6 class="card-title mb-1 text-dark">${provider.providerName}</h6>
                                <small class="text-muted">
                                    <c:choose>
                                        <c:when test="${provider.providerType == 'TEL'}">Điện thoại</c:when>
                                        <c:otherwise>Game</c:otherwise>
                                    </c:choose>
                                </small>
                            </div>
                        </div>
                    </a>
                </div>
            </c:forEach>
        </div>
    </section>

    <!-- Products Grouped by Provider -->
    <section>
        <h2 class="section-title">Sản Phẩm Theo Nhà Cung Cấp</h2>

        <c:choose>
        <c:when test="${empty productsByProvider}">
            <div class="alert alert-info">
                Hiện tại chưa có sản phẩm nào.  Vui lòng quay lại sau.
            </div>
        </c:when>
        <c:otherwise>
        <c:forEach var="entry" items="${productsByProvider}">
        <c:set var="provider" value="${entry.key}" />
        <c:set var="products" value="${entry.value}" />

        <div class="provider-section">
            <!-- Provider Header -->
            <div class="provider-section-header">
                <c:choose>
                <c:when test="${not empty provider.imageUrl}">
                    <img src="${provider.imageUrl}" alt="${provider.providerName}">
                    </c:when>
                    <c:otherwise>
                        <div class="provider-icon-placeholder">
                            <c:choose>
                                <c:when test="${provider.providerType == 'TEL'}">
                                <i class="bi bi-phone-fill"></i>
                                </c:when>
                                <c:otherwise>
                                    <i class="bi bi-controller"></i>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </c:otherwise>
                    </c:choose>
                    <h4 class="mb-0">${provider.providerName}</h4>
                    <span class="badge provider-type-badge ${provider.providerType == 'TEL' ? 'bg-primary' : 'bg-success'}">
                                        <c:choose>
                                            <c:when test="${provider.providerType == 'TEL'}">Điện thoại</c:when>
                <c:otherwise>Game</c:otherwise>
                </c:choose>
                </span>
                <a href="products?providerId=${provider.providerId}"class="ms-auto btn btn-sm btn-outline-secondary">
                    Xem tất cả →
                </a>
            </div>

            <!-- Product Grid -->
            <div class="row g-3">
                <c:forEach var="product" items="${products}">
                    <div class="col-6 col-md-4 col-lg-3">
                        <div class="card product-card ${product.availableCount == 0 ? 'out-of-stock' : ''}">
                            <c:choose>
                            <c:when test="${not empty product.imageUrl}">
                                <img src="${product.imageUrl}" class="card-img-top" alt="${product.productName}">
                            </c:when>
                            <c:otherwise>
                                <div class="card-img-top d-flex align-items-center justify-content-center bg-light">
                                    <c:choose>
                                        <c:when test="${product.providerType == 'TEL'}">
                                            <i class="bi bi-credit-card-2-front" style="font-size: 3rem; color: #6c757d;"></i>
                                        </c:when>
                                        <c:otherwise>
                                            <i class="bi bi-controller" style="font-size: 3rem; color: #6c757d;"></i>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </c:otherwise>
                            </c:choose>
                            <div class="card-body">
                                <h5 class="card-title">${product.productName}</h5>
                                <p class="product-price mb-2">
                                    <fmt:formatNumber value="${product.price}" type="number" maxFractionDigits="0"/> đ
                                </p>
                                <div class="mb-3">
                                    <c:choose>
                                        <c:when test="${product.availableCount > 0}">
                                                                <span class="badge bg-success stock-badge">
                                                                    Còn ${product.availableCount} thẻ
                                                                </span>
                                        </c:when>
                                        <c:otherwise>
                                                                <span class="badge bg-secondary stock-badge">
                                                                    Hết hàng
                                                                </span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <a href="product-detail?id=${product.productId}"
                                   class="btn btn-dark btn-sm w-100 mt-auto ${product.availableCount == 0 ?  'disabled' :  ''}">
                                    <c:choose>
                                        <c:when test="${product.availableCount > 0}">Mua ngay</c:when>
                                        <c:otherwise>Hết hàng</c:otherwise>
                                    </c:choose>
                                </a>
                            </div>
                        </div>
                    </div>
                    </c:forEach>
            </div>
        </div>
        </c:forEach>
        </c:otherwise>
        </c:choose>
    </section>

</div>

<%@include file="../components/footer.jsp" %>
</body>
</html>