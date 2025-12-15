package authentication_controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import DAO.user.RegisterDAO;

/**
 * Servlet để kiểm tra email đã tồn tại chưa (AJAX)
 */
@WebServlet(name = "RegisterCheckController", urlPatterns = {"/registercheck"})
public class RegisterCheckController extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/plain; charset=UTF-8");
        
        String email = request.getParameter("email");
        
        System.out.println("RegisterCheckController - Email received: [" + email + "]");
        
        if (email == null || email.trim().isEmpty()) {
            System.out.println("Email is empty, returning 0");
            response.getWriter().write("0");
            return;
        }
        
        RegisterDAO registerDAO = new RegisterDAO();
        boolean exists = registerDAO.checkEmailExists(email);
        
        System.out.println("Email exists check result: " + exists);
        
        // Trả về "1" nếu email đã tồn tại, "0" nếu chưa
        response.getWriter().write(exists ? "1" : "0");
    }
}

