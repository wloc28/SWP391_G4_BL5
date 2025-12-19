package controller.user;

import DAO.admin.TransactionDAO;
import DAO.user.daoUser;
import Models.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;

/**
 * WalletServlet - handle wallet deposit (top-up) for users.
 * URL: /wallet
 */
@WebServlet(name = "WalletServlet", urlPatterns = { "/wallet" })
public class WalletServlet extends HttpServlet {

    private TransactionDAO transactionDAO;
    private daoUser userDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            transactionDAO = new TransactionDAO();
            userDAO = new daoUser();
        } catch (Exception e) {
            throw new ServletException("Failed to initialize WalletServlet DAOs", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();

        User user = (User) session.getAttribute("info");
        if (user == null) {
            user = (User) session.getAttribute("user");
        }

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/view/login.jsp");
            return;
        }

        BigDecimal balance = user.getBalance() != null ? user.getBalance() : BigDecimal.ZERO;
        request.setAttribute("balance", balance);

        request.getRequestDispatcher("/view/WalletDeposit.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();

        User user = (User) session.getAttribute("info");
        if (user == null) {
            user = (User) session.getAttribute("user");
        }

        if (user == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Vui lòng đăng nhập");
            return;
        }

        String amountStr = request.getParameter("amount");
        String method = request.getParameter("method");

        if (amountStr == null || amountStr.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập số tiền cần nạp");
            doGet(request, response);
            return;
        }

        try {
            BigDecimal amount = new BigDecimal(amountStr.trim());
            if (amount.compareTo(BigDecimal.ZERO) <= 0) {
                request.setAttribute("error", "Số tiền nạp phải lớn hơn 0");
                doGet(request, response);
                return;
            }

            // Simple upper limit to avoid test mistakes
            if (amount.compareTo(new BigDecimal("100000000")) > 0) {
                request.setAttribute("error", "Số tiền nạp quá lớn");
                doGet(request, response);
                return;
            }

            BigDecimal currentBalance = user.getBalance() != null ? user.getBalance() : BigDecimal.ZERO;
            BigDecimal newBalance = currentBalance.add(amount);

            // Update balance in DB
            boolean balanceUpdated = transactionDAO.updateUserBalance(user.getUserId(), newBalance);
            if (!balanceUpdated) {
                request.setAttribute("error", "Không thể cập nhật số dư. Vui lòng thử lại.");
                doGet(request, response);
                return;
            }

            // Create deposit transaction (simulated payment gateway success)
            String gateway = (method != null && !method.isEmpty()) ? method : "INTERNAL";
            String description = "Nạp ví qua " + gateway;

            boolean transactionCreated = transactionDAO.createTransaction(
                    user.getUserId(),
                    null,
                    amount,
                    "DEPOSIT",
                    description
            );

            if (!transactionCreated) {
                // Attempt rollback
                try {
                    transactionDAO.updateUserBalance(user.getUserId(), currentBalance);
                } catch (Exception ignored) {
                }

                request.setAttribute("error", "Không thể ghi nhận giao dịch nạp tiền. Vui lòng thử lại.");
                doGet(request, response);
                return;
            }

            // Reload user from DB to get fresh balance
            User updatedUser = userDAO.getUserById(user.getUserId());
            if (updatedUser != null) {
                if (session.getAttribute("info") != null) {
                    session.setAttribute("info", updatedUser);
                }
                if (session.getAttribute("user") != null) {
                    session.setAttribute("user", updatedUser);
                }
                request.setAttribute("balance", updatedUser.getBalance());
            } else {
                // Fallback
                user.setBalance(newBalance);
                if (session.getAttribute("info") != null) {
                    session.setAttribute("info", user);
                }
                if (session.getAttribute("user") != null) {
                    session.setAttribute("user", user);
                }
                request.setAttribute("balance", newBalance);
            }

            request.setAttribute("success", "Nạp tiền thành công " + amount.toPlainString() + " đ");
            request.getRequestDispatcher("/view/WalletDeposit.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Số tiền không hợp lệ");
            doGet(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi khi nạp tiền: " + e.getMessage());
            doGet(request, response);
        }
    }
}



