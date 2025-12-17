<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Chi Tiết Sản Phẩm</title>
        <%@include file="../components/libs.jsp" %>
        <script src="https://cdn.tailwindcss.com"></script>
    </head>
    <body>
        <%@include file="../components/header_v2.jsp" %>
        <div class="w-full px-4 py-6">
            <div class="max-w-6xl mx-auto">
                <!-- Error Message -->
                <c:if test="${not empty error}">
                    <div class="bg-red-50 border border-red-200 rounded-lg p-3 mb-4">
                        <div class="flex justify-between items-center">
                            <p class="text-red-800 text-sm">${error}</p>
                            <button type="button" onclick="this.parentElement.parentElement.remove()" class="text-red-600 hover:text-red-800">
                                <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                                    <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd"></path>
                                </svg>
                            </button>
                        </div>
                    </div>
                    <a href="products" class="inline-block bg-gray-900 text-white px-3 py-1.5 rounded text-sm hover:bg-gray-800 transition-colors font-medium mb-4">Quay lại</a>
                </c:if>
                
                <!-- Product Detail -->
                <c:if test="${not empty product}">
                    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                        <!-- Product Image -->
                        <div>
                            <c:choose>
                                <c:when test="${not empty product.imageUrl}">
                                    <img src="${product.imageUrl}" class="w-full rounded-lg border border-gray-200 bg-gray-100" 
                                         alt="${product.productName}" 
                                         onerror="this.src='https://via.placeholder.com/500x500?text=No+Image'">
                                </c:when>
                                <c:otherwise>
                                    <img src="https://via.placeholder.com/500x500?text=No+Image" 
                                         class="w-full rounded-lg border border-gray-200 bg-gray-100" alt="${product.productName}">
                                </c:otherwise>
                            </c:choose>
                        </div>
                        
                        <!-- Product Information -->
                        <div>
                            <div class="bg-white border border-gray-200 rounded-lg shadow-sm p-5">
                                <h1 class="text-2xl font-bold text-gray-900 mb-3">${product.productName}</h1>
                                
                                <!-- Provider Info -->
                                <div class="flex gap-2 mb-3">
                                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">${product.provider.providerName}</span>
                                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">${product.provider.providerType}</span>
                                </div>
                                
                                <!-- Price -->
                                <div class="mb-4 pb-4 border-b border-gray-200">
                                    <p class="text-xs text-gray-600 mb-0.5">Giá bán</p>
                                    <p class="text-3xl font-bold text-gray-900">
                                        <fmt:formatNumber value="${product.price}" type="number" maxFractionDigits="0" /> đ
                                    </p>
                                </div>
                                
                                <!-- Stock Status -->
                                <div class="mb-4">
                                    <c:choose>
                                        <c:when test="${stock > 0}">
                                            <span class="inline-flex items-center px-3 py-1.5 rounded text-xs font-medium bg-green-100 text-green-800">
                                                Còn hàng: ${stock} sản phẩm
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="inline-flex items-center px-3 py-1.5 rounded text-xs font-medium bg-red-100 text-red-800">
                                                Hết hàng
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                
                                <!-- Description -->
                                <c:if test="${not empty product.description}">
                                    <div class="mb-4">
                                        <h3 class="text-sm font-semibold text-gray-900 mb-1.5">Mô tả sản phẩm</h3>
                                        <p class="text-sm text-gray-600 leading-relaxed">${product.description}</p>
                                    </div>
                                </c:if>
                                
                                <!-- Product Details -->
                                <div class="mb-4">
                                    <h3 class="text-sm font-semibold text-gray-900 mb-2">Thông tin sản phẩm</h3>
                                    <dl class="grid grid-cols-2 gap-2">
                                        <div class="bg-gray-50 px-3 py-2 rounded">
                                            <dt class="text-xs font-medium text-gray-500">Mã SP</dt>
                                            <dd class="mt-0.5 text-xs text-gray-900">#${product.productId}</dd>
                                        </div>
                                        <div class="bg-gray-50 px-3 py-2 rounded">
                                            <dt class="text-xs font-medium text-gray-500">Nhà cung cấp</dt>
                                            <dd class="mt-0.5 text-xs text-gray-900">${product.provider.providerName}</dd>
                                        </div>
                                        <div class="bg-gray-50 px-3 py-2 rounded">
                                            <dt class="text-xs font-medium text-gray-500">Loại</dt>
                                            <dd class="mt-0.5 text-xs text-gray-900">
                                                <c:choose>
                                                    <c:when test="${product.provider.providerType == 'TEL'}">Thẻ điện thoại</c:when>
                                                    <c:when test="${product.provider.providerType == 'GAME'}">Thẻ game</c:when>
                                                    <c:otherwise>${product.provider.providerType}</c:otherwise>
                                                </c:choose>
                                            </dd>
                                        </div>
                                        <div class="bg-gray-50 px-3 py-2 rounded">
                                            <dt class="text-xs font-medium text-gray-500">Trạng thái</dt>
                                            <dd class="mt-0.5">
                                                <c:choose>
                                                    <c:when test="${product.status == 'ACTIVE'}">
                                                        <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-green-100 text-green-800">Đang bán</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-gray-100 text-gray-800">Ngừng bán</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </dd>
                                        </div>
                                    </dl>
                                </div>
                                
                                <!-- Action Buttons -->
                                <div class="flex gap-2">
                                    <c:choose>
                                        <c:when test="${sessionScope.info == null and sessionScope.user == null}">
                                            <button onclick="alert('Vui lòng đăng nhập để mua hàng!'); window.location.href='${pageContext.request.contextPath}/view/login.jsp';" 
                                                    class="flex-1 bg-gray-900 text-white px-4 py-2 rounded hover:bg-gray-800 transition-colors font-medium text-sm">
                                                Đăng nhập để mua hàng
                                            </button>
                                        </c:when>
                                        <c:when test="${stock > 0 && product.status == 'ACTIVE'}">
                                            <button onclick="addToCart(${product.productId})" 
                                                    class="flex-1 bg-gray-900 text-white px-4 py-2 rounded hover:bg-gray-800 transition-colors font-medium text-sm">
                                                Thêm vào giỏ hàng
                                            </button>
                                        </c:when>
                                        <c:otherwise>
                                            <button disabled 
                                                    class="flex-1 bg-gray-300 text-gray-500 px-4 py-2 rounded cursor-not-allowed font-medium text-sm">
                                                Không thể mua
                                            </button>
                                        </c:otherwise>
                                    </c:choose>
                                    <a href="products" class="bg-white text-gray-700 border border-gray-300 px-4 py-2 rounded hover:bg-gray-50 transition-colors font-medium text-sm text-center">
                                        Quay lại
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:if>
            </div>
        </div>
        
        <%@include file="../components/footer.jsp" %>
        
        <script>
            <c:set var="isLoggedIn" value="${sessionScope.info != null or sessionScope.user != null}" />
            function addToCart(productId) {
                <c:choose>
                    <c:when test="${!isLoggedIn}">
                        alert('Vui lòng đăng nhập để mua hàng!');
                        window.location.href = '${pageContext.request.contextPath}/view/login.jsp';
                        return;
                    </c:when>
                    <c:otherwise>
                // TODO: Implement add to cart functionality
                alert('Tính năng thêm vào giỏ hàng sẽ được triển khai sau. Product ID: ' + productId);
                // You can implement AJAX call here to add product to cart
                // Example:
                // fetch('add-to-cart', {
                //     method: 'POST',
                //     headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                //     body: 'productId=' + productId
                // })
                    </c:otherwise>
                </c:choose>
            }
        </script>
    </body>
</html>
