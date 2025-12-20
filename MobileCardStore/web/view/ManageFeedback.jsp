<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Quản lý phản hồi</title>
        <%@include file="../components/libs.jsp" %>
        <style>
            .content-cell {
                max-width: 400px;
                word-wrap: break-word;
                white-space: normal;
            }
            .reply-box {
                margin-top: 8px;
                padding: 8px;
                background-color: #f8f9fa;
                border-left: 3px solid #007bff;
            }
        </style>
    </head>
    <body>
        <%@include file="../components/header_v2.jsp" %>

        <div class="container py-4">
            <h2>Quản lý phản hồi</h2>

            <c:if test="${not empty error}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="bi bi-exclamation-circle me-2"></i>${error}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            
            <c:if test="${param.error == 'reply_too_long'}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="bi bi-exclamation-circle me-2"></i>
                    Nội dung phản hồi không được vượt quá 100 ký tự!
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <!-- Filter Section -->
            <div class="card mb-4">
                <div class="card-body">
                    <form method="GET" action="${pageContext.request.contextPath}/admin/feedback" onsubmit="document.getElementById('pageInput').value='1'">
                        <input type="hidden" name="page" value="1" id="pageInput">
                        <div class="row g-3">
                            <!-- Tìm kiếm -->
                            <div class="col-md-4">
                                <label class="form-label">Tìm kiếm</label>
                                <input type="text" name="search" class="form-control" 
                                       placeholder="Tên user, email, nội dung..." 
                                       value="${searchValue}">
                            </div>
                            
                            <!-- Filter theo rating -->
                            <div class="col-md-2">
                                <label class="form-label">Đánh giá</label>
                                <select name="rating" class="form-select">
                                    <option value="">Tất cả đánh giá</option>
                                    <option value="5" ${ratingValue == '5' ? 'selected' : ''}>5 sao</option>
                                    <option value="4" ${ratingValue == '4' ? 'selected' : ''}>4 sao</option>
                                    <option value="3" ${ratingValue == '3' ? 'selected' : ''}>3 sao</option>
                                    <option value="2" ${ratingValue == '2' ? 'selected' : ''}>2 sao</option>
                                    <option value="1" ${ratingValue == '1' ? 'selected' : ''}>1 sao</option>
                                    <option value="0" ${ratingValue == '0' ? 'selected' : ''}>Chưa đánh giá</option>
                                </select>
                            </div>
                            
                            <!-- Filter theo trạng thái reply -->
                            <div class="col-md-2">
                                <label class="form-label">Trạng thái phản hồi</label>
                                <select name="hasReply" class="form-select">
                                    <option value="">Tất cả</option>
                                    <option value="yes" ${hasReplyValue == 'yes' ? 'selected' : ''}>Đã phản hồi</option>
                                    <option value="no" ${hasReplyValue == 'no' ? 'selected' : ''}>Chưa phản hồi</option>
                                </select>
                            </div>
                            
                            <!-- Sắp xếp -->
                            <div class="col-md-2">
                                <label class="form-label">Sắp xếp</label>
                                <select name="sortBy" class="form-select">
                                    <option value="newest" ${sortByValue == 'newest' || empty sortByValue ? 'selected' : ''}>Mới nhất</option>
                                    <option value="oldest" ${sortByValue == 'oldest' ? 'selected' : ''}>Cũ nhất</option>
                                    <option value="rating_high" ${sortByValue == 'rating_high' ? 'selected' : ''}>Rating cao</option>
                                    <option value="rating_low" ${sortByValue == 'rating_low' ? 'selected' : ''}>Rating thấp</option>
                                    <option value="no_reply" ${sortByValue == 'no_reply' ? 'selected' : ''}>Chưa phản hồi</option>
                                </select>
                            </div>
                            
                            <!-- Buttons -->
                            <div class="col-md-2 d-flex align-items-end">
                                <button type="submit" class="btn btn-primary me-2">
                                    <i class="bi bi-funnel"></i> Lọc
                                </button>
                                <a href="${pageContext.request.contextPath}/admin/feedback" class="btn btn-secondary">
                                    <i class="bi bi-arrow-clockwise"></i> Reset
                                </a>
                            </div>
                        </div>
                    </form>
                </div>
            </div>

            <table class="table table-bordered">
                <thead>
                    <tr>
                        <th style="width: 50px;">ID</th>
                        <th style="width: 150px;">User</th>
                        <th style="width: 100px;">Sản phẩm</th>
                        <th style="width: 400px;">Nội dung</th>
                        <th style="width: 80px;">Đánh giá</th>
                        <th style="width: 120px;">Thời gian</th>
                        <th style="width: 200px;">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="feedback" items="${feedbacks}">
                        <tr>
                            <td>${feedback.feedbackId}</td>
                            <td>
                                ${feedback.user.fullName}<br>
                                <small class="text-muted">${feedback.user.email}</small>
                            </td>
                            <td>${feedback.productName}</td>
                            <td class="content-cell">
                                <c:if test="${not empty feedback.content}">
                                    ${feedback.content}
                                </c:if>
                                <c:if test="${empty feedback.content}">
                                    <span class="text-muted">(Không có nội dung)</span>
                                </c:if>

                                <c:if test="${not empty feedback.adminReply}">
                                    <div class="reply-box">
                                        <strong>CSKH:</strong> ${feedback.adminReply}
                                        <br><small class="text-muted">
                                            <fmt:formatDate value="${feedback.adminReplyAt}" pattern="dd/MM/yyyy HH:mm" />
                                        </small>
                                    </div>
                                </c:if>
                            </td>
                            <td>
                                <c:if test="${not empty feedback.rating}">
                                    <strong>${feedback.rating}/5</strong>
                                </c:if>
                                <c:if test="${empty feedback.rating}">
                                    <span class="text-muted">-</span>
                                </c:if>
                            </td>
                            <td>
                                <small>
                                    <fmt:formatDate value="${feedback.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                </small>
                            </td>
                            <td>
                                <div class="d-flex gap-1 align-items-center">
                                    <button onclick="toggleReplyForm(${feedback.feedbackId})" class="btn btn-sm btn-primary">
                                        <i class="bi bi-chat-left-text"></i> ${empty feedback.adminReply ? 'Phản hồi' : 'Sửa phản hồi'}
                                    </button>

                                    <form action="${pageContext.request.contextPath}/admin/feedback" method="POST" class="d-inline">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="feedbackId" value="${feedback.feedbackId}">
                                        <c:if test="${not empty searchValue}">
                                            <input type="hidden" name="search" value="${searchValue}">
                                        </c:if>
                                        <c:if test="${not empty productIdValue}">
                                            <input type="hidden" name="productId" value="${productIdValue}">
                                        </c:if>
                                        <c:if test="${not empty ratingValue}">
                                            <input type="hidden" name="rating" value="${ratingValue}">
                                        </c:if>
                                        <c:if test="${not empty hasReplyValue}">
                                            <input type="hidden" name="hasReply" value="${hasReplyValue}">
                                        </c:if>
                                        <c:if test="${not empty sortByValue}">
                                            <input type="hidden" name="sortBy" value="${sortByValue}">
                                        </c:if>
                                        <button type="submit" class="btn btn-sm btn-danger" 
                                                onclick="return confirm('Bạn có chắc muốn xóa?')">
                                            <i class="bi bi-trash"></i> Xóa
                                        </button>
                                    </form>
                                </div>

                                <div id="replyForm_${feedback.feedbackId}" style="display: none;" class="mt-2">
                                    <form action="${pageContext.request.contextPath}/admin/feedback" method="POST">
                                        <input type="hidden" name="action" value="reply">
                                        <input type="hidden" name="feedbackId" value="${feedback.feedbackId}">
                                        <c:if test="${not empty searchValue}">
                                            <input type="hidden" name="search" value="${searchValue}">
                                        </c:if>
                                        <c:if test="${not empty productIdValue}">
                                            <input type="hidden" name="productId" value="${productIdValue}">
                                        </c:if>
                                        <c:if test="${not empty ratingValue}">
                                            <input type="hidden" name="rating" value="${ratingValue}">
                                        </c:if>
                                        <c:if test="${not empty hasReplyValue}">
                                            <input type="hidden" name="hasReply" value="${hasReplyValue}">
                                        </c:if>
                                        <c:if test="${not empty sortByValue}">
                                            <input type="hidden" name="sortBy" value="${sortByValue}">
                                        </c:if>
                                        <textarea name="replyContent" 
                                                  id="replyContent_${feedback.feedbackId}"
                                                  rows="4" 
                                                  class="form-control mb-1" 
                                                  required
                                                  maxlength="100"
                                                  oninput="updateReplyCharCount(this, 'replyCount_${feedback.feedbackId}')"
                                                  placeholder="Nhập nội dung phản hồi (tối đa 100 ký tự)...">${feedback.adminReply}</textarea>
                                        <div class="text-sm text-muted mb-2">
                                            <span id="replyCount_${feedback.feedbackId}">${fn:length(feedback.adminReply)}</span>/100 ký tự
                                        </div>
                                        <button type="submit" class="btn btn-sm btn-success">Gửi</button>
                                        <c:if test="${not empty feedback.adminReply}">
                                            <c:url var="removeReplyUrl" value="/admin/feedback">
                                                <c:param name="action" value="remove_reply"/>
                                                <c:param name="feedbackId" value="${feedback.feedbackId}"/>
                                                <c:if test="${not empty searchValue}">
                                                    <c:param name="search" value="${searchValue}"/>
                                                </c:if>
                                                <c:if test="${not empty productIdValue}">
                                                    <c:param name="productId" value="${productIdValue}"/>
                                                </c:if>
                                                <c:if test="${not empty ratingValue}">
                                                    <c:param name="rating" value="${ratingValue}"/>
                                                </c:if>
                                                <c:if test="${not empty hasReplyValue}">
                                                    <c:param name="hasReply" value="${hasReplyValue}"/>
                                                </c:if>
                                                <c:if test="${not empty sortByValue}">
                                                    <c:param name="sortBy" value="${sortByValue}"/>
                                                </c:if>
                                            </c:url>
                                            <a href="${removeReplyUrl}" 
                                               class="btn btn-sm btn-danger"
                                               onclick="return confirm('Bạn có chắc muốn xóa phản hồi?')">Xóa</a>
                                        </c:if>
                                        <button type="button" onclick="toggleReplyForm(${feedback.feedbackId})" 
                                                class="btn btn-sm btn-secondary">Hủy</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>

            <c:if test="${empty feedbacks}">
                <p class="text-center text-muted py-4">Không có feedback nào.</p>
            </c:if>
            
            <!-- Pagination Info -->
            <c:if test="${totalCount > 0}">
                <div class="d-flex justify-content-between align-items-center mb-3 mt-3">
                    <div class="text-muted">
                        Hiển thị <strong>${startItem}</strong> - <strong>${endItem}</strong> 
                        của <strong>${totalCount}</strong> phản hồi
                    </div>
                </div>
            </c:if>

            <!-- Pagination -->
            <c:if test="${totalPages > 1}">
                <nav aria-label="Page navigation">
                    <ul class="pagination justify-content-center">
                        <!-- Previous Button -->
                        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                            <c:url var="prevUrl" value="/admin/feedback">
                                <c:param name="page" value="${currentPage - 1}"/>
                                <c:if test="${not empty searchValue}">
                                    <c:param name="search" value="${searchValue}"/>
                                </c:if>
                                <c:if test="${not empty productIdValue}">
                                    <c:param name="productId" value="${productIdValue}"/>
                                </c:if>
                                <c:if test="${not empty ratingValue}">
                                    <c:param name="rating" value="${ratingValue}"/>
                                </c:if>
                                <c:if test="${not empty hasReplyValue}">
                                    <c:param name="hasReply" value="${hasReplyValue}"/>
                                </c:if>
                                <c:if test="${not empty sortByValue}">
                                    <c:param name="sortBy" value="${sortByValue}"/>
                                </c:if>
                            </c:url>
                            <a class="page-link" href="${prevUrl}" ${currentPage == 1 ? 'tabindex="-1" aria-disabled="true"' : ''}>
                                <i class="bi bi-chevron-left"></i> Trước
                            </a>
                        </li>
                        
                        <!-- Page Numbers -->
                        <c:choose>
                            <c:when test="${totalPages <= 7}">
                                <!-- Hiển thị tất cả nếu <= 7 trang -->
                                <c:forEach var="i" begin="1" end="${totalPages}">
                                    <li class="page-item ${i == currentPage ? 'active' : ''}">
                                        <c:url var="pageUrl" value="/admin/feedback">
                                            <c:param name="page" value="${i}"/>
                                            <c:if test="${not empty searchValue}">
                                                <c:param name="search" value="${searchValue}"/>
                                            </c:if>
                                            <c:if test="${not empty productIdValue}">
                                                <c:param name="productId" value="${productIdValue}"/>
                                            </c:if>
                                            <c:if test="${not empty ratingValue}">
                                                <c:param name="rating" value="${ratingValue}"/>
                                            </c:if>
                                            <c:if test="${not empty hasReplyValue}">
                                                <c:param name="hasReply" value="${hasReplyValue}"/>
                                            </c:if>
                                            <c:if test="${not empty sortByValue}">
                                                <c:param name="sortBy" value="${sortByValue}"/>
                                            </c:if>
                                        </c:url>
                                        <a class="page-link" href="${pageUrl}">${i}</a>
                                    </li>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <!-- Hiển thị với ellipsis nếu > 7 trang -->
                                <c:if test="${currentPage > 1}">
                                    <li class="page-item">
                                        <c:url var="firstUrl" value="/admin/feedback">
                                            <c:param name="page" value="1"/>
                                            <c:if test="${not empty searchValue}"><c:param name="search" value="${searchValue}"/></c:if>
                                            <c:if test="${not empty productIdValue}"><c:param name="productId" value="${productIdValue}"/></c:if>
                                            <c:if test="${not empty ratingValue}"><c:param name="rating" value="${ratingValue}"/></c:if>
                                            <c:if test="${not empty hasReplyValue}"><c:param name="hasReply" value="${hasReplyValue}"/></c:if>
                                            <c:if test="${not empty sortByValue}"><c:param name="sortBy" value="${sortByValue}"/></c:if>
                                        </c:url>
                                        <a class="page-link" href="${firstUrl}">1</a>
                                    </li>
                                    <c:if test="${currentPage > 3}">
                                        <li class="page-item disabled">
                                            <span class="page-link">...</span>
                                        </li>
                                    </c:if>
                                </c:if>
                                
                                <c:forEach var="i" begin="${currentPage > 2 ? currentPage - 1 : 2}" 
                                           end="${currentPage < totalPages - 1 ? currentPage + 1 : totalPages - 1}">
                                    <li class="page-item ${i == currentPage ? 'active' : ''}">
                                        <c:url var="pageUrl" value="/admin/feedback">
                                            <c:param name="page" value="${i}"/>
                                            <c:if test="${not empty searchValue}"><c:param name="search" value="${searchValue}"/></c:if>
                                            <c:if test="${not empty productIdValue}"><c:param name="productId" value="${productIdValue}"/></c:if>
                                            <c:if test="${not empty ratingValue}"><c:param name="rating" value="${ratingValue}"/></c:if>
                                            <c:if test="${not empty hasReplyValue}"><c:param name="hasReply" value="${hasReplyValue}"/></c:if>
                                            <c:if test="${not empty sortByValue}"><c:param name="sortBy" value="${sortByValue}"/></c:if>
                                        </c:url>
                                        <a class="page-link" href="${pageUrl}">${i}</a>
                                    </li>
                                </c:forEach>
                                
                                <c:if test="${currentPage < totalPages}">
                                    <c:if test="${currentPage < totalPages - 2}">
                                        <li class="page-item disabled">
                                            <span class="page-link">...</span>
                                        </li>
                                    </c:if>
                                    <li class="page-item">
                                        <c:url var="lastUrl" value="/admin/feedback">
                                            <c:param name="page" value="${totalPages}"/>
                                            <c:if test="${not empty searchValue}"><c:param name="search" value="${searchValue}"/></c:if>
                                            <c:if test="${not empty productIdValue}"><c:param name="productId" value="${productIdValue}"/></c:if>
                                            <c:if test="${not empty ratingValue}"><c:param name="rating" value="${ratingValue}"/></c:if>
                                            <c:if test="${not empty hasReplyValue}"><c:param name="hasReply" value="${hasReplyValue}"/></c:if>
                                            <c:if test="${not empty sortByValue}"><c:param name="sortBy" value="${sortByValue}"/></c:if>
                                        </c:url>
                                        <a class="page-link" href="${lastUrl}">${totalPages}</a>
                                    </li>
                                </c:if>
                            </c:otherwise>
                        </c:choose>
                        
                        <!-- Next Button -->
                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                            <c:url var="nextUrl" value="/admin/feedback">
                                <c:param name="page" value="${currentPage + 1}"/>
                                <c:if test="${not empty searchValue}">
                                    <c:param name="search" value="${searchValue}"/>
                                </c:if>
                                <c:if test="${not empty productIdValue}">
                                    <c:param name="productId" value="${productIdValue}"/>
                                </c:if>
                                <c:if test="${not empty ratingValue}">
                                    <c:param name="rating" value="${ratingValue}"/>
                                </c:if>
                                <c:if test="${not empty hasReplyValue}">
                                    <c:param name="hasReply" value="${hasReplyValue}"/>
                                </c:if>
                                <c:if test="${not empty sortByValue}">
                                    <c:param name="sortBy" value="${sortByValue}"/>
                                </c:if>
                            </c:url>
                            <a class="page-link" href="${nextUrl}" ${currentPage == totalPages ? 'tabindex="-1" aria-disabled="true"' : ''}>
                                Tiếp <i class="bi bi-chevron-right"></i>
                            </a>
                        </li>
                    </ul>
                </nav>
            </c:if>
        </div>

        <script>
            function toggleReplyForm(feedbackId) {
                const form = document.getElementById('replyForm_' + feedbackId);
                form.style.display = form.style.display === 'none' ? 'block' : 'none';
            }
        </script>
        <%@include file="../components/footer.jsp" %>
    </body>
</html>
