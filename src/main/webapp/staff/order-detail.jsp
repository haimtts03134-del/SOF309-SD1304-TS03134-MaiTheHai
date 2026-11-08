<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="common/staff-header.jsp" />

<!-- Khối hiển thị khi xem bình thường trên Web (Ẩn khi In) -->
<div class="d-print-none">
    <div class="row mb-3">
        <div class="col-12">
            <a href="${pageContext.request.contextPath}/staff/orders" class="btn btn-sm btn-outline-secondary px-3" style="border-radius: 8px;">
                <i class="bi bi-arrow-left me-1"></i> Quay lại danh sách
            </a>
        </div>
    </div>

    <div class="row mb-4">
        <div class="col-12 d-flex justify-content-between align-items-center">
            <h2 class="fw-bold text-dark mb-0">Đơn Hàng #${order.maHoaDon}</h2>
            <div>
                <c:choose>
                    <c:when test="${order.trangThai == 'ChoThanhToan'}">
                        <span class="badge-status status-chothanhtoan">Chờ thanh toán</span>
                    </c:when>
                    <c:when test="${order.trangThai == 'DangCheBien'}">
                        <span class="badge-status status-dangchebien">Đang chế biến</span>
                    </c:when>
                    <c:when test="${order.trangThai == 'DaGiao'}">
                        <span class="badge-status status-dagiao">Đã giao món</span>
                    </c:when>
                    <c:when test="${order.trangThai == 'DaThanhToan'}">
                        <span class="badge-status status-dathanhtoan">Đã thanh toán</span>
                    </c:when>
                    <c:when test="${order.trangThai == 'DaHuy'}">
                        <span class="badge-status status-dahuy">Đã hủy</span>
                    </c:when>
                </c:choose>
            </div>
        </div>
    </div>

    <!-- Hiển thị thông báo kết quả hành động -->
    <c:if test="${not empty sessionScope.orderSuccess}">
        <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm mb-4" role="alert" style="border-radius: 10px;">
            <i class="bi bi-check-circle-fill me-2"></i> ${sessionScope.orderSuccess}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <c:if test="${not empty sessionScope.orderError}">
        <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm mb-4" role="alert" style="border-radius: 10px;">
            <i class="bi bi-exclamation-triangle-fill me-2"></i> ${sessionScope.orderError}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <div class="row g-4">
        <!-- Cột trái: Chi tiết món nước đã gọi -->
        <div class="col-12 col-lg-8">
            <div class="custom-card">
                <h5 class="fw-bold mb-4 border-bottom pb-2">
                    <i class="bi bi-cup-straw text-warning me-2"></i>Danh Sách Món Đã Đặt
                </h5>
                
                <div class="table-responsive">
                    <table class="table table-hover align-middle custom-table">
                        <thead>
                            <tr>
                                <th style="width: 70px;">Món</th>
                                <th>Tên Đồ Uống</th>
                                <th class="text-end">Đơn Giá</th>
                                <th class="text-center" style="width: 80px;">SL</th>
                                <th class="text-end">Thành Tiền</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="detail" items="${order.orderDetails}">
                                <tr>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty detail.drink.hinhAnh}">
                                                <c:set var="detailImg" value="${detail.drink.hinhAnh}" />
                                                <c:if test="${!detail.drink.hinhAnh.startsWith('http') && !detail.drink.hinhAnh.startsWith('data:') && !detail.drink.hinhAnh.startsWith('/')}">
                                                    <c:set var="detailImg" value="${pageContext.request.contextPath}/admin/images/${detail.drink.hinhAnh}" />
                                                </c:if>
                                                <img src="${detailImg}" class="rounded border" 
                                                     style="width: 50px; height: 50px; object-fit: cover;" 
                                                     alt="${detail.drink.tenSanPham}"
                                                     onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/images/${detail.drink.hinhAnh}';">
                                            </c:when>
                                            <c:otherwise>
                                                <div class="rounded border bg-light text-muted d-flex align-items-center justify-content-center" style="width: 50px; height: 50px;">
                                                    <i class="bi bi-image fs-5"></i>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="fw-bold text-dark">${detail.drink.tenSanPham}</div>
                                        <c:if test="${not empty detail.ghiChu}">
                                            <small class="text-danger fw-semibold bg-danger-subtle px-2 py-0.5 rounded border border-danger-subtle" style="font-size: 0.8rem;">
                                                <i class="bi bi-chat-left-dots me-1"></i>Yêu cầu: ${detail.ghiChu}
                                            </small>
                                        </c:if>
                                    </td>
                                    <td class="text-end text-muted">
                                        <fmt:formatNumber value="${detail.donGia}" type="currency" currencySymbol="đ" maxFractionDigits="0" />
                                    </td>
                                    <td class="text-center fw-semibold text-dark">
                                        x${detail.soLuong}
                                    </td>
                                    <td class="text-end fw-bold text-success">
                                        <fmt:formatNumber value="${detail.donGia * detail.soLuong}" type="currency" currencySymbol="đ" maxFractionDigits="0" />
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>

                <div class="row mt-4 pt-3 border-top">
                    <!-- Ghi chú của đơn hàng -->
                    <div class="col-12">
                        <label class="form-label text-secondary" style="font-size: 0.9rem;">
                            <i class="bi bi-pencil-square me-1"></i> Ghi chú đơn hàng (Khách hàng yêu cầu):
                        </label>
                        <div class="bg-light p-3 rounded text-dark" style="min-height: 50px; border-left: 4px solid var(--secondary-gold);">
                            ${not empty order.ghiChu ? order.ghiChu : 'Không có ghi chú nào từ khách hàng.'}
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Nhập ghi chú của nhân viên -->
            <div class="custom-card">
                <h5 class="fw-bold mb-3">
                    <i class="bi bi-chat-text text-warning me-2"></i>Cập Nhật Ghi Chú & Lưu Ý Của Nhân Viên
                </h5>
                <form action="${pageContext.request.contextPath}/staff/orders/detail" method="post">
                    <input type="hidden" name="id" value="${order.maHoaDon}">
                    <input type="hidden" name="status" value="${order.trangThai}">
                    <div class="mb-3">
                        <textarea class="form-control" name="note" rows="3" placeholder="Nhập thêm ghi chú phục vụ hoặc lưu ý thanh toán tại đây...">${order.ghiChu}</textarea>
                    </div>
                    <button type="submit" class="btn btn-outline-warning px-4" style="border-radius: 8px;">
                        <i class="bi bi-save me-1"></i> Lưu ghi chú
                    </button>
                </form>
            </div>
        </div>

        <!-- Cột phải: Thông tin đơn hàng & Thao tác nghiệp vụ -->
        <div class="col-12 col-lg-4">
            <div class="custom-card">
                <h5 class="fw-bold mb-4 border-bottom pb-2">
                    <i class="bi bi-info-circle text-warning me-2"></i>Thông Tin Thanh Toán
                </h5>
                
                <ul class="list-unstyled mb-4">
                    <li class="d-flex justify-content-between mb-3">
                        <span class="text-muted">Phương thức:</span>
                        <c:choose>
                            <c:when test="${order.loaiHoaDon == 'TaiCho'}">
                                <strong class="text-success"><i class="bi bi-shop me-1"></i>${not empty order.table ? order.table.tenBan : 'Tại quán'}</strong>
                            </c:when>
                            <c:otherwise>
                                <strong class="text-primary"><i class="bi bi-bag-dash me-1"></i>Mang về</strong>
                            </c:otherwise>
                        </c:choose>
                    </li>
                    <li class="d-flex justify-content-between mb-3">
                        <span class="text-muted">Khách hàng:</span>
                        <strong class="text-dark">${order.customer.hoTen}</strong>
                    </li>
                    <li class="d-flex justify-content-between mb-3">
                        <span class="text-muted">Số điện thoại:</span>
                        <strong class="text-dark">${order.customer.soDienThoai}</strong>
                    </li>
                    <li class="d-flex justify-content-between mb-3">
                        <span class="text-muted">Điểm hiện tại:</span>
                        <span class="badge bg-secondary-subtle text-dark border fw-bold">${order.customer.diemTichLuy} điểm</span>
                    </li>
                    <li class="d-flex justify-content-between mb-3">
                        <span class="text-muted">Ngày đặt:</span>
                        <span class="text-dark"><fmt:formatDate value="${order.ngayTao}" pattern="dd/MM/yyyy HH:mm" /></span>
                    </li>
                    <li class="d-flex justify-content-between mb-3">
                        <span class="text-muted">Nhân viên phụ trách:</span>
                        <strong class="text-secondary">${not empty order.user ? order.user.hoTen : 'Chưa nhận'}</strong>
                    </li>
                    <hr>
                    <li class="d-flex justify-content-between mb-1">
                        <span class="text-muted" style="font-size: 1.1rem;">Tổng tiền cần thu:</span>
                        <span class="fs-4 fw-bold text-success">
                            <fmt:formatNumber value="${order.tongTien}" type="currency" currencySymbol="đ" maxFractionDigits="0" />
                        </span>
                    </li>
                    <c:if test="${order.trangThai != 'DaThanhToan' && order.trangThai != 'DaHuy'}">
                        <li class="text-end text-muted">
                            <small class="text-danger fw-semibold bg-warning-subtle px-2 py-0.5 rounded border border-warning-subtle">
                                <i class="bi bi-star-fill text-warning me-1"></i> +${(int)(order.tongTien / 10000)} điểm tích lũy khi thanh toán
                            </small>
                        </li>
                    </c:if>
                </ul>
                
                <!-- Nút thao tác của nhân viên -->
                <div class="d-grid gap-2 btn-action-container">
                    <c:if test="${order.trangThai != 'DaThanhToan' && order.trangThai != 'DaHuy'}">
                        <c:set var="itemsStr" value="" />
                        <c:forEach var="detail" items="${order.orderDetails}" varStatus="vs">
                            <c:set var="itemsStr" value="${itemsStr}${detail.soLuong}x ${detail.drink.tenSanPham}${!vs.last ? ', ' : ''}" />
                        </c:forEach>
                        <button type="button" class="btn btn-success py-2.5 fw-bold" style="border-radius: 8px;"
                                data-bs-toggle="modal" 
                                data-bs-target="#paymentConfirmModal"
                                data-id="${order.maHoaDon}"
                                data-customer-name="${order.customer.hoTen}"
                                data-customer-phone="${order.customer.soDienThoai}"
                                data-staff-name="${not empty order.user ? order.user.hoTen : 'Chưa nhận'}"
                                data-total-amount="${order.tongTien}"
                                data-items="${itemsStr}">
                            <i class="bi bi-currency-dollar me-1"></i> Xác Nhận Đã Thanh Toán
                        </button>
                        <hr class="my-2 d-print-none">
                    </c:if>

                    <c:choose>
                        <c:when test="${order.trangThai == 'ChoThanhToan'}">
                            <form action="${pageContext.request.contextPath}/staff/orders/detail" method="post" class="d-grid">
                                <input type="hidden" name="id" value="${order.maHoaDon}">
                                <input type="hidden" name="status" value="DangCheBien">
                                <button type="submit" class="btn btn-warning py-2.5 fw-bold" style="border-radius: 8px;">
                                    <i class="bi bi-fire me-1"></i> Xác Nhận Chế Biến
                                </button>
                            </form>
                        </c:when>
                        
                        <c:when test="${order.trangThai == 'DangCheBien'}">
                            <form action="${pageContext.request.contextPath}/staff/orders/detail" method="post" class="d-grid">
                                <input type="hidden" name="id" value="${order.maHoaDon}">
                                <input type="hidden" name="status" value="DaGiao">
                                <button type="submit" class="btn btn-primary py-2.5 fw-bold" style="border-radius: 8px;">
                                    <i class="bi bi-check2-circle me-1"></i> Giao Đồ Uống Cho Khách
                                </button>
                            </form>
                        </c:when>
                    </c:choose>
                    
                    <!-- Nút Hủy Đơn Hàng (Chỉ hiển thị khi chưa hoàn thành hoặc chưa hủy) -->
                    <c:if test="${order.trangThai != 'DaThanhToan' && order.trangThai != 'DaHuy'}">
                        <form action="${pageContext.request.contextPath}/staff/orders/detail" method="post" class="d-grid">
                            <input type="hidden" name="id" value="${order.maHoaDon}">
                            <input type="hidden" name="status" value="DaHuy">
                            <button type="submit" class="btn btn-outline-danger py-2" style="border-radius: 8px;"
                                    onclick="return confirm('Bạn có chắc chắn muốn hủy đơn hàng này không? (Điểm tích lũy nếu có sẽ bị trừ lại)');">
                                <i class="bi bi-x-circle me-1"></i> Hủy Đơn Hàng
                            </button>
                        </form>
                    </c:if>

                    <!-- Nút In hóa đơn tạm tính -->
                    <button type="button" class="btn btn-outline-secondary py-2" style="border-radius: 8px;" onclick="window.print();">
                        <i class="bi bi-printer me-1"></i> In Hóa Đơn (Bill K80)
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- ==========================================================================
   Khối HTML dành riêng cho In hóa đơn (Mặc định ẩn trên màn hình, chỉ hiện khi in)
   ========================================================================== -->
<div class="d-none d-print-block print-invoice-card" style="width: 75mm; font-family: 'Courier New', Courier, monospace; font-size: 12px; margin: 0 auto; color: #000; padding: 5px 0;">
    <div style="text-align: center; margin-bottom: 15px;">
        <h4 style="margin: 0; font-size: 16px; font-weight: bold; letter-spacing: 1px;">QR COFFEE POLY</h4>
        <div style="font-size: 10px; margin-top: 3px;">
            Đ/c: 123 Đường Tô Ký, Quận 12, TP.HCM<br>
            SĐT: 0912 345 678
        </div>
        <div style="border-top: 1px dashed #000; margin: 10px 0;"></div>
        <strong style="font-size: 13px;">HÓA ĐƠN TẠM TÍNH</strong>
        <div style="border-top: 1px dashed #000; margin: 10px 0;"></div>
    </div>
    
    <div style="margin-bottom: 12px; font-size: 11px; line-height: 1.4;">
        Mã hóa đơn: #${order.maHoaDon}<br>
        Ngày đặt: <fmt:formatDate value="${order.ngayTao}" pattern="dd/MM/yyyy HH:mm:ss" /><br>
        Vị trí: <strong>${order.loaiHoaDon == 'TaiCho' ? (not empty order.table ? order.table.tenBan : 'Tại quán') : 'Mang về'}</strong><br>
        Khách hàng: ${order.customer.hoTen} (${order.customer.soDienThoai})<br>
        Nhân viên: ${not empty order.user ? order.user.hoTen : 'Chưa nhận'}
    </div>
    
    <div style="border-top: 1px dashed #000; margin: 8px 0;"></div>
    
    <table style="width: 100%; border-collapse: collapse; font-size: 11px; line-height: 1.4;">
        <thead>
            <tr style="border-bottom: 1px dashed #000;">
                <th style="text-align: left; padding-bottom: 5px;">Tên món</th>
                <th style="text-align: center; width: 30px; padding-bottom: 5px;">SL</th>
                <th style="text-align: right; width: 70px; padding-bottom: 5px;">T.Tiền</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="detail" items="${order.orderDetails}">
                <tr>
                    <td style="padding: 4px 0;">
                        ${detail.drink.tenSanPham}
                        <c:if test="${not empty detail.ghiChu}">
                            <br><small style="font-size: 9px; font-style: italic;">*Y/c: ${detail.ghiChu}</small>
                        </c:if>
                    </td>
                    <td style="text-align: center; padding: 4px 0;">${detail.soLuong}</td>
                    <td style="text-align: right; padding: 4px 0;"><fmt:formatNumber value="${detail.donGia * detail.soLuong}" type="currency" currencySymbol="" maxFractionDigits="0" /></td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
    
    <div style="border-top: 1px dashed #000; margin: 10px 0;"></div>
    
    <div style="display: flex; justify-content: space-between; font-weight: bold; font-size: 13px; padding: 4px 0;">
        <span>TỔNG CẦN THU:</span>
        <span><fmt:formatNumber value="${order.tongTien}" type="currency" currencySymbol="đ" maxFractionDigits="0" /></span>
    </div>
    
    <div style="border-top: 1px dashed #000; margin: 10px 0;"></div>
    
    <div style="text-align: center; font-size: 10px; margin-top: 15px; line-height: 1.4;">
        Xin cảm ơn quý khách hàng!<br>
        Chúc quý khách một ngày vui vẻ!
    </div>
</div>

<%
    session.removeAttribute("orderSuccess");
    session.removeAttribute("orderError");
%>

<!-- Modal Xác Nhận Thanh Toán -->
<div class="modal fade" id="paymentConfirmModal" tabindex="-1" aria-labelledby="paymentConfirmModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 16px;">
            <div class="modal-header bg-success text-white py-3" style="border-radius: 16px 16px 0 0;">
                <h5 class="modal-title fw-bold" id="paymentConfirmModalLabel">
                    <i class="bi bi-check2-circle me-2"></i>Xác Nhận Thanh Toán Đơn Hàng
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="${pageContext.request.contextPath}/staff/orders/detail" method="post" class="m-0">
                <input type="hidden" name="id" id="modalOrderId" value="">
                <input type="hidden" name="status" value="DaThanhToan">
                
                <div class="modal-body p-4">
                    <div class="text-center mb-4">
                        <span class="text-muted small uppercase tracking-wider d-block mb-1">MÃ HÓA ĐƠN</span>
                        <h3 class="fw-bold text-success mb-0 fs-2" id="displayOrderId">#00</h3>
                    </div>
                    
                    <div class="row g-3 mb-3">
                        <div class="col-6">
                            <span class="text-muted small d-block mb-1"><i class="bi bi-person me-1"></i>Khách Hàng</span>
                            <strong class="text-dark fs-6 d-block" id="displayCustomerName">Tên Khách</strong>
                        </div>
                        <div class="col-6">
                            <span class="text-muted small d-block mb-1"><i class="bi bi-telephone me-1"></i>Số Điện Thoại</span>
                            <strong class="text-dark fs-6 d-block" id="displayCustomerPhone">090****000</strong>
                        </div>
                    </div>
                    
                    <div class="mb-4">
                        <span class="text-muted small d-block mb-1"><i class="bi bi-person-badge me-1"></i>Nhân Viên Phụ Trách</span>
                        <strong class="text-secondary d-block" id="displayStaffName">Tên Nhân Viên</strong>
                    </div>
                    
                    <div class="mb-4">
                        <span class="text-muted small d-block mb-2"><i class="bi bi-receipt me-1"></i>Danh Sách Món Đã Đặt</span>
                        <div class="bg-light p-3 rounded-3 border border-light" id="displayDrinkItems" style="max-height: 160px; overflow-y: auto;">
                            <!-- JS will inject list items here -->
                        </div>
                    </div>
                    
                    <div class="d-flex justify-content-between align-items-center bg-success-subtle p-3 rounded-3 border border-success-subtle">
                        <span class="fs-6 text-success-emphasis fw-bold">Tổng tiền cần thu:</span>
                        <span class="fs-3 fw-black text-success" id="displayTotalAmount" style="font-weight: 800;">0 đ</span>
                    </div>
                </div>
                
                <div class="modal-footer border-0 p-3 pt-0 d-flex gap-2">
                    <button type="button" class="btn btn-light border flex-grow-1 py-2 fw-semibold" data-bs-dismiss="modal" style="border-radius: 10px;">
                        Hủy
                    </button>
                    <button type="submit" class="btn btn-success flex-grow-1 py-2 fw-bold" style="border-radius: 10px;">
                        <i class="bi bi-credit-card-2-back me-1"></i> Xác Nhận Thanh Toán
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="common/staff-footer.jsp" />
