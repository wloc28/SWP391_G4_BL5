package authentication_controller;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Authentication Filter để kiểm tra session và phân quyền
 */
@WebFilter(filterName = "AuthFilter", urlPatterns = {"/view/*", "/index_1.html", "/admin/*"})
public class AuthFilter implements Filter {
    
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Không cần init
    }
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);
        
        String requestURI = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        String path = requestURI.substring(contextPath.length());
        
        // Tạm thời bỏ qua auth cho toàn bộ admin (yêu cầu user -> bỏ login)
        if (path.startsWith("/admin/")) {
            chain.doFilter(request, response);
            return;
        }
        
        // Cho phép truy cập các trang/public không cần đăng nhập
        if (path.equals("/view/login.jsp") || 
            path.equals("/login") ||
            path.equals("/logout") ||
            path.equals("/view/register.jsp") ||
            path.equals("/register") ||
            // Quên mật khẩu + OTP + đặt lại mật khẩu
            path.equals("/view/ForgotPassword.jsp") ||
            path.equals("/forgotpassword") ||
            path.equals("/view/ForgotPasswordOTP.jsp") ||
            path.equals("/view/ResetPassword.jsp") ||
            path.equals("/resetpassword") ||
            // Static / components
            path.startsWith("/components/") ||
            path.startsWith("/public/") ||
            path.startsWith("/dist/") ||
            path.startsWith("/js/") ||
            path.startsWith("/css/") ||
            path.startsWith("/img/")) {
            chain.doFilter(request, response);
            return;
        }
        
        // Kiểm tra session
        if (session == null || session.getAttribute("user") == null) {
            // Chưa đăng nhập, redirect về trang login
            httpResponse.sendRedirect(contextPath + "/view/login.jsp");
            return;
        }
        
        // Lấy role từ session
        String role = (String) session.getAttribute("role");
        
        // Kiểm tra phân quyền cho trang admin (index_1.html và /admin/*)
        if (path.equals("/index_1.html") || path.startsWith("/admin/")) {
            if (role == null || !role.equalsIgnoreCase("ADMIN")) {
                // Không phải admin, redirect về trang customer
                httpResponse.sendRedirect(contextPath + "/view/testlogin.jsp");
                return;
            }
        }
        
        // Kiểm tra phân quyền cho trang customer (testlogin.jsp)
        if (path.equals("/view/testlogin.jsp")) {
            if (role != null && role.equalsIgnoreCase("ADMIN")) {
                // Admin không được vào trang customer, redirect về dashboard
                httpResponse.sendRedirect(contextPath + "/admin/dashboard");
                return;
            }
        }
        
        // Cho phép truy cập
        chain.doFilter(request, response);
    }
    
    @Override
    public void destroy() {
        // Không cần cleanup
    }
}

