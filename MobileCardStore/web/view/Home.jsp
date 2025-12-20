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
                            <c:when test="${not empty product.providerImageUrl}">
                                <img src="${product.providerImageUrl}" class="card-img-top" alt="${product.productName}" 
                                     style="height: 200px; object-fit: contain; padding: 10px;">
                            </c:when>
                            <c:otherwise>
                                <div class="card-img-top d-flex align-items-center justify-content-center bg-light" style="height: 200px;">
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
                                <c:choose>
                                    <c:when test="${product.availableCount == 0}">
                                        <button class="btn btn-secondary btn-sm w-100 mt-auto" disabled>
                                            Hết hàng
                                        </button>
                                    </c:when>
                                    <c:when test="${sessionScope.info == null and sessionScope.user == null}">
                                        <a href="${pageContext.request.contextPath}/view/login.jsp"
                                           class="btn btn-dark btn-sm w-100 mt-auto">
                                            Đăng nhập để mua
                                        </a>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="d-flex gap-1 mt-auto">
                                            <a href="product-detail?code=${product.productCode}&providerId=${product.providerId}"
                                               class="btn btn-outline-primary btn-sm flex-fill">
                                                <i class="bi bi-eye"></i> Chi tiết
                                            </a>
                                            <button onclick="addToCart('${product.productCode}', ${product.providerId}, 1)"
                                                    class="btn btn-outline-success btn-sm flex-fill">
                                                <i class="bi bi-cart-plus"></i> Thêm
                                            </button>
                                            <button onclick="buyNow('${product.productCode}', ${product.providerId})"
                                                    class="btn btn-dark btn-sm flex-fill">
                                                <i class="bi bi-bag-check"></i> Mua ngay
                                            </button>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
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

<script>
    <c:set var="isLoggedIn" value="${sessionScope.info != null or sessionScope.user != null}" />
    <c:set var="contextPath" value="${pageContext.request.contextPath}" />
    
    function addToCart(productCode, providerId, quantity) {
        <c:if test="${!isLoggedIn}">
            alert('Vui lòng đăng nhập để mua hàng!');
            window.location.href = '${contextPath}/view/login.jsp';
            return;
        </c:if>
        
        const button = event.target.closest('button');
        const originalText = button.innerHTML;
        
        // Disable button and show loading
        button.disabled = true;
        button.innerHTML = '<i class="bi bi-hourglass-split"></i>';
        
        // Thêm vào giỏ hàng
        fetch('${contextPath}/cart/add', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'productCode=' + encodeURIComponent(productCode) + 
                  '&providerId=' + providerId + 
                  '&quantity=' + (quantity || 1)
        })
        .then(response => {
            if (response.ok) {
                return response.json();
            } else {
                return response.text().then(text => {
                    throw new Error(text || 'Có lỗi xảy ra');
                });
            }
        })
        .then(data => {
            if (data.success) {
                // Hiển thị thành công
                button.innerHTML = '<i class="bi bi-check-circle-fill text-success"></i>';
                button.classList.add('btn-success');
                button.classList.remove('btn-outline-success');
                
                // Trigger cart update event để cập nhật badge
                const cartUpdatedEvent = new Event('cartUpdated');
                document.dispatchEvent(cartUpdatedEvent);
                
                // Cập nhật badge giỏ hàng
                updateCartBadge();
                
                // Khôi phục button sau 2 giây
                setTimeout(() => {
                    button.innerHTML = originalText;
                    button.classList.remove('btn-success');
                    button.classList.add('btn-outline-success');
                    button.disabled = false;
                }, 2000);
            } else {
                alert(data.message || 'Có lỗi xảy ra');
                button.innerHTML = originalText;
                button.disabled = false;
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Có lỗi xảy ra khi thêm sản phẩm vào giỏ hàng: ' + error.message);
            button.innerHTML = originalText;
            button.disabled = false;
        });
    }
    
    // Hàm cập nhật badge giỏ hàng
    function updateCartBadge() {
        <c:if test="${isLoggedIn}">
        // Cập nhật badge bằng cách reload trang hoặc fetch số lượng
        // Đơn giản nhất là reload trang để cập nhật badge
        // Hoặc có thể fetch số lượng từ API nếu có
        const badge = document.getElementById('cartBadge');
        if (badge) {
            // Trigger animation
            badge.style.animation = 'pulse 0.5s ease-in-out';
            setTimeout(() => {
                badge.style.animation = '';
                // Reload để cập nhật số lượng chính xác
                window.location.reload();
            }, 500);
        } else {
            // Nếu chưa có badge, reload để hiển thị
            setTimeout(() => {
                window.location.reload();
            }, 500);
        }
        </c:if>
    }
    
    function buyNow(productCode, providerId) {
        <c:if test="${!isLoggedIn}">
            alert('Vui lòng đăng nhập để mua hàng!');
            window.location.href = '${contextPath}/view/login.jsp';
            return;
        </c:if>
        
        const button = event.target.closest('button');
        const originalText = button.innerHTML;
        
        // Disable button and show loading
        button.disabled = true;
        button.innerHTML = '<i class="bi bi-hourglass-split"></i> ...';
        
        // Thêm vào giỏ hàng trước
        fetch('${contextPath}/cart/add', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'productCode=' + encodeURIComponent(productCode) + 
                  '&providerId=' + providerId + 
                  '&quantity=1'
        })
        .then(response => {
            if (response.ok) {
                return response.json();
            } else {
                return response.text().then(text => {
                    throw new Error(text || 'Có lỗi xảy ra');
                });
            }
        })
        .then(data => {
            if (data.success) {
                // Thêm thành công, chuyển đến trang giỏ hàng
                window.location.href = '${contextPath}/cart/view';
            } else {
                alert(data.message || 'Có lỗi xảy ra khi thêm sản phẩm vào giỏ hàng');
                button.innerHTML = originalText;
                button.disabled = false;
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Có lỗi xảy ra khi thêm sản phẩm vào giỏ hàng: ' + error.message);
            button.innerHTML = originalText;
            button.disabled = false;
        });
    }
</script>

</body>
</html>