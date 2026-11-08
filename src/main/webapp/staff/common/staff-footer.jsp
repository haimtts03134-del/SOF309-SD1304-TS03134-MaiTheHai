<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
</div> <!-- Đóng thẻ div .container -->

<footer class="footer mt-auto py-3 bg-white border-top no-print">
    <div class="container text-center">
        <span class="text-muted">© 2026 QRCoffeePoly. Hệ thống nhận đơn và xử lý nhanh dành cho nhân viên phục vụ & bếp.</span>
    </div>
</footer>

<!-- Bootstrap 5 JS Bundle (Bao gồm Popper) -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<!-- Script Heartbeat (Ping) giữ đăng nhập liên tục & Điều khiển Modal Xác nhận thanh toán -->
<script>
    document.addEventListener("DOMContentLoaded", function () {
        // 1. Gửi yêu cầu ping ngầm mỗi 5 phút để duy trì session
        const PING_INTERVAL = 5 * 60 * 1000;
        const pingUrl = "${pageContext.request.contextPath}/staff/orders?action=ping";

        function sendSessionHeartbeat() {
            fetch(pingUrl)
                .then(response => {
                    if (response.ok) {
                        console.log("Heartbeat: Giữ kết nối session thành công lúc " + new Date().toLocaleTimeString());
                    } else {
                        console.warn("Heartbeat: Không kết nối được với server. Mã lỗi: " + response.status);
                    }
                })
                .catch(error => {
                    console.error("Heartbeat: Lỗi kết nối mạng: ", error);
                });
        }

        setInterval(sendSessionHeartbeat, PING_INTERVAL);
        setTimeout(sendSessionHeartbeat, 2000);

        // 2. Điền dữ liệu động vào Modal Xác nhận thanh toán khi được mở
        const paymentModal = document.getElementById('paymentConfirmModal');
        if (paymentModal) {
            paymentModal.addEventListener('show.bs.modal', function (event) {
                const button = event.relatedTarget; // Nút bấm kích hoạt modal
                if (!button) return;
                
                // Lấy thông tin từ các thuộc tính data-* của nút
                const orderId = button.getAttribute('data-id');
                const customerName = button.getAttribute('data-customer-name');
                const customerPhone = button.getAttribute('data-customer-phone');
                const staffName = button.getAttribute('data-staff-name');
                const totalAmount = button.getAttribute('data-total-amount');
                const items = button.getAttribute('data-items');

                // Điền dữ liệu vào các thẻ tương ứng
                document.getElementById('modalOrderId').value = orderId;
                document.getElementById('displayOrderId').textContent = '#' + orderId;
                document.getElementById('displayCustomerName').textContent = customerName ? customerName : 'Khách vãng lai';
                
                // Che số điện thoại (Ví dụ: 090****636)
                let maskedPhone = 'Không có SĐT';
                if (customerPhone && customerPhone.trim().length >= 6) {
                    const phoneStr = customerPhone.trim();
                    maskedPhone = phoneStr.substring(0, 3) + "****" + phoneStr.substring(phoneStr.length - 3);
                } else if (customerPhone) {
                    maskedPhone = customerPhone;
                }
                document.getElementById('displayCustomerPhone').textContent = maskedPhone;
                
                document.getElementById('displayStaffName').textContent = staffName;
                
                // Định dạng tiền tệ bằng JS (ví dụ: 39000 -> 39.000 đ)
                let formattedAmount = totalAmount;
                if (totalAmount && !isNaN(totalAmount)) {
                    formattedAmount = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' })
                                        .format(totalAmount).replace('₫', 'đ');
                }
                document.getElementById('displayTotalAmount').textContent = formattedAmount;

                // Xử lý danh sách các món nước
                const itemsContainer = document.getElementById('displayDrinkItems');
                itemsContainer.innerHTML = '';
                if (items && items.trim().length > 0) {
                    const itemList = items.split(', ');
                    const ul = document.createElement('ul');
                    ul.className = 'list-unstyled mb-0';
                    itemList.forEach(item => {
                        const li = document.createElement('li');
                        li.className = 'mb-1 py-1 border-bottom border-light';
                        li.innerHTML = '<i class="bi bi-cup-hot text-warning me-2"></i>' + item;
                        ul.appendChild(li);
                    });
                    itemsContainer.appendChild(ul);
                } else {
                    itemsContainer.innerHTML = '<span class="text-muted italic">Không có thông tin món ăn</span>';
                }
            });
        }
    });
</script>

<!-- Script Tự động kiểm tra & Thông báo đơn hàng mới (Real-time Order Auto Notifier) -->
<script src="${pageContext.request.contextPath}/common/js/order-auto-notifier.js"></script>

<!-- Script Tự động kiểm tra & Thông báo cập nhật chấm công (Real-time Attendance Auto Notifier) -->
<script src="${pageContext.request.contextPath}/common/js/attendance-auto-notifier.js"></script>
</body>
</html>
