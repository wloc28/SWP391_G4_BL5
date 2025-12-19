<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Nạp tiền vào ví</title>
        <%@include file="../components/libs.jsp" %>
        <script src="https://cdn.tailwindcss.com"></script>
    </head>
    <body>
        <%@include file="../components/header_v2.jsp" %>

        <div class="w-full px-4 py-6">
            <div class="max-w-xl mx-auto">
                <!-- Back button -->
                <a href="${pageContext.request.contextPath}/home" 
                   class="inline-flex items-center text-sm text-gray-600 hover:text-gray-900 mb-4">
                    <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path>
                    </svg>
                    Quay lại trang chủ
                </a>
                
                <h1 class="text-2xl font-semibold text-gray-900 mb-4">Nạp tiền vào ví</h1>

                <!-- Messages -->
                <c:if test="${not empty error}">
                    <div class="bg-red-50 border border-red-200 rounded-lg p-3 mb-4 text-sm text-red-800">
                        ${error}
                    </div>
                </c:if>
                <c:if test="${not empty success}">
                    <div class="bg-green-50 border border-green-200 rounded-lg p-3 mb-4 text-sm text-green-800">
                        ${success}
                    </div>
                </c:if>

                <!-- Current balance -->
                <div class="bg-white border border-gray-200 rounded-lg shadow-sm p-4 mb-4">
                    <p class="text-sm text-gray-600 mb-1">Số dư hiện tại</p>
                    <p class="text-2xl font-bold text-green-600">
                        <fmt:formatNumber value="${balance}" type="number" maxFractionDigits="0" /> đ
                    </p>
                </div>

                <!-- Deposit form (PayOS) -->
                <div class="bg-white border border-gray-200 rounded-lg shadow-sm p-4">
                    <form method="POST" action="${pageContext.request.contextPath}/wallet/payos" class="space-y-4">
                        <div>
                            <label for="amount" class="block text-sm font-medium text-gray-700 mb-1">Số tiền nạp</label>
                            <input type="number"
                                   id="amount"
                                   name="amount"
                                   min="1000"
                                   step="1000"
                                   required
                                   class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                                   placeholder="Nhập số tiền (vd: 50000)">
                            <p class="mt-1 text-xs text-gray-500">Tối thiểu 1.000đ, khuyến nghị nạp bội số 10.000đ.</p>
                        </div>

                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-1">Phương thức thanh toán</label>
                            <p class="text-sm text-gray-800 mb-1">PayOS</p>
                            <p class="mt-1 text-xs text-gray-500">
                                Sau khi bấm <strong>“Thanh toán PayOS”</strong>, bạn sẽ được chuyển sang trang PayOS.
                                Khi thanh toán thành công, hệ thống sẽ tự động cộng tiền vào ví.
                            </p>
                        </div>

                        <button type="submit"
                                class="w-full bg-gray-900 text-white px-4 py-2.5 rounded-lg text-sm font-medium hover:bg-gray-800 transition-colors">
                            Thanh toán PayOS
                        </button>
                    </form>
                </div>
            </div>
        </div>

        <%@include file="../components/footer.jsp" %>
    </body>
</html>

