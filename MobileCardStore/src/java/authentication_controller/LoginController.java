/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package authentication_controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Cookie;
import DAO.user.daoUser;
import Models.User;

/**
 *
 * @author Dell XPS
 */
@WebServlet(name="LoginServlet", urlPatterns={"/login"})
public class LoginController extends HttpServlet {
   
    /** 
     * Handles the HTTP <code>GET</code> method.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        // Redirect to login page
        request.getRequestDispatcher("/view/login.jsp").forward(request, response);
    } 

    /** 
     * Handles the HTTP <code>POST</code> method.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        // Get parameters from form
                              String email = request.getParameter("user");
        String password = request.getParameter("pass");
        
        // Validate input
        if (email == null || email.trim().isEmpty() || 
            password == null || password.trim().isEmpty()) {
            request.setAttribute("passmsg", "Email và mật khẩu không được để trống!");
            request.getRequestDispatcher("/view/login.jsp").forward(request, response);
            return;
        }
        
        // Attempt login
        daoUser customerLogin = new daoUser();
        User user = customerLogin.login(email.trim(), password);
        
        if (user != null) {
            // Login successful
            HttpSession session = request.getSession();
            session.setAttribute("user", user);
            session.setAttribute("userId", user.getUserId());
            session.setAttribute("username", user.getUsername());
            session.setAttribute("email", user.getEmail());
            session.setAttribute("role", user.getRole());
            
            // Redirect based on role
            String role = user.getRole();
            if (role != null && role.equalsIgnoreCase("ADMIN")) {
                // Admin redirect to index_1.html
                response.sendRedirect(request.getContextPath() + "/index_1.html");
            } else {
                // Customer redirect to testlogin.jsp
                response.sendRedirect(request.getContextPath() + "/view/testlogin.jsp");
            }
        } else {
            // Login failed
            request.setAttribute("passmsg", "Email hoặc mật khẩu không đúng!");
            request.getRequestDispatcher("/view/login.jsp").forward(request, response);
        }
    }

    /** 
     * Returns a short description of the servlet.
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Login Controller Servlet";
    }
}
