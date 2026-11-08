<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="common/header.jsp" />

<div class="container-fluid py-4">
    <!-- Tiêu đề trang -->
    <div class="row mb-4 align-items-center">
        <div class="col-md-7">
            <h2 class="fw-bold text-dark"><i class="bi bi-grid-3x3-gap-fill text-warning me-2"></i>Quản Lý Số Bàn & Vị Trí</h2>
            <p class="text-muted mb-0">Quản lý danh sách bàn ăn, tạo và in mã QR Code vị trí đặt món cho khách hàng.</p>
        </div>
        <div class="col-md-5 text-md-end mt-3 mt-md-0">
            <a href="${pageContext.request.contextPath}/admin/tables" class="btn btn-outline-secondary fw-semibold rounded-pill px-3 me-2">
                <i class="bi bi-arrow-clockwise me-1"></i> Làm mới
            </a>
            <a href="#formTable" class="btn btn-warning fw-semibold shadow-sm text-dark rounded-pill px-3">
                <i class="bi bi-plus-circle-fill me-1"></i> Thêm Bàn Mới
            </a>
        </div>
    </div>

    <!-- Hiển thị thông báo thành công hoặc lỗi -->
    <c:if test="${not empty sessionScope.tableSuccess}">
        <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm mb-4" role="alert" style="border-radius: 12px;">
            <i class="bi bi-check-circle-fill me-2"></i> ${sessionScope.tableSuccess}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <c:remove var="tableSuccess" scope="session" />
    </c:if>

    <c:if test="${not empty sessionScope.tableError}">
        <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm mb-4" role="alert" style="border-radius: 12px;">
            <i class="bi bi-exclamation-triangle-fill me-2"></i> ${sessionScope.tableError}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <c:remove var="tableError" scope="session" />
    </c:if>

    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm mb-4" role="alert" style="border-radius: 12px;">
            <i class="bi bi-exclamation-triangle-fill me-2"></i> ${errorMessage}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <!-- Thống kê số lượng bàn dạng Widget Cards -->
    <div class="row g-3 mb-4">
        <!-- Tổng số bàn -->
        <div class="col-12 col-md-6">
            <div class="card border-0 shadow-sm rounded-4 h-100 p-3" style="background: linear-gradient(135deg, #2b5876 0%, #4e4376 100%); color: #fff;">
                <div class="d-flex align-items-center justify-content-between">
                    <div>
                        <span class="text-white-50 small fw-semibold">Tổng Số Bàn Ăn</span>
                        <h3 class="fw-bold my-1">${totalTables} bàn</h3>
                        <small class="text-white-50" style="font-size: 0.75rem;">Toàn bộ sơ đồ bàn tại quán</small>
                    </div>
                    <div class="rounded-circle p-3 bg-white bg-opacity-10 fs-3">
                        <i class="bi bi-grid-3x3-gap"></i>
                    </div>
                </div>
            </div>
        </div>

        <!-- Trạng thái mã QR -->
        <div class="col-12 col-md-6">
            <div class="card border-0 shadow-sm rounded-4 h-100 p-3" style="background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%); color: #fff;">
                <div class="d-flex align-items-center justify-content-between">
                    <div>
                        <span class="text-white-50 small fw-semibold">Mã QR Code Vị Trí</span>
                        <h3 class="fw-bold my-1">${totalTables} mã QR</h3>
                        <small class="text-white-50" style="font-size: 0.75rem;">Sẵn sàng in dán bàn & quét món</small>
                    </div>
                    <div class="rounded-circle p-3 bg-white bg-opacity-10 fs-3">
                        <i class="bi bi-qr-code-scan"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Khối Nội Dung Chính: Cột Trái Form Nhập & Cột Phải Danh Sách Bàn -->
    <div class="row g-4">
        <!-- Cột Trái: Form Thêm Mới / Chỉnh Sửa Bàn -->
        <div class="col-12 col-lg-4" id="formTable">
            <div class="card border-0 shadow-sm rounded-4 p-4 sticky-top" style="top: 20px; background-color: #ffffff;">
                <h5 class="fw-bold text-dark mb-3 pb-2 border-bottom">
                    <c:choose>
                        <c:when test="${isEdit}">
                            <i class="bi bi-pencil-square text-warning me-2"></i>Cập Nhật Thông Tin Bàn
                        </c:when>
                        <c:otherwise>
                            <i class="bi bi-plus-circle text-success me-2"></i>Thêm Bàn Mới
                        </c:otherwise>
                    </c:choose>
                </h5>

                <form action="${pageContext.request.contextPath}/admin/tables" method="post">
                    <input type="hidden" name="action" value="${isEdit ? 'update' : 'insert'}">
                    <c:if test="${isEdit}">
                        <input type="hidden" name="id" value="${selectedTable.maBan}">
                    </c:if>

                    <!-- Tên Bàn -->
                    <div class="mb-3">
                        <label for="tenBan" class="form-label fw-semibold text-secondary">Tên bàn <span class="text-danger">*</span></label>
                        <input type="text" class="form-control form-control-lg rounded-3" id="tenBan" name="tenBan" 
                               placeholder="Ví dụ: Bàn 01, Bàn VIP 02" value="${selectedTable.tenBan}" required>
                    </div>

                    <!-- Mã Code QR -->
                    <div class="mb-3">
                        <label for="maCodeQR" class="form-label fw-semibold text-secondary">Mã Code QR (Tùy chọn)</label>
                        <input type="text" class="form-control rounded-3" id="maCodeQR" name="maCodeQR" 
                               placeholder="Ví dụ: TABLE_01 (Để trống tự sinh)" value="${selectedTable.maCodeQR}">
                        <small class="text-muted d-block mt-1">Dùng để quét mã QR nhận diện vị trí bàn tự động.</small>
                    </div>



                    <div class="d-grid gap-2">
                        <button type="submit" class="btn ${isEdit ? 'btn-warning' : 'btn-success'} btn-lg fw-bold rounded-3 shadow-sm">
                            <i class="bi ${isEdit ? 'bi-check-circle-fill' : 'bi-plus-lg'} me-1"></i>
                            ${isEdit ? 'Lưu Cập Nhật' : 'Tạo Bàn Mới'}
                        </button>
                        <c:if test="${isEdit}">
                            <a href="${pageContext.request.contextPath}/admin/tables" class="btn btn-outline-secondary rounded-3 fw-semibold">
                                Hủy Chỉnh Sửa
                            </a>
                        </c:if>
                    </div>
                </form>
            </div>
        </div>

        <!-- Cột Phải: Bảng Danh Sách Các Bàn -->
        <div class="col-12 col-lg-8">
            <div class="card border-0 shadow-sm rounded-4 p-4" style="background-color: #ffffff;">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h5 class="fw-bold text-dark mb-0">
                        <i class="bi bi-list-stars text-warning me-2"></i>Danh Sách Số Bàn Hiện Có (${tables.size()})
                    </h5>
                    <div class="input-group input-group-sm w-auto">
                        <input type="text" id="searchTableInput" class="form-control rounded-pill px-3" placeholder="Tìm tên bàn..." onkeyup="filterTables()">
                    </div>
                </div>

                <div class="table-responsive">
                    <table class="table table-hover align-middle custom-table mb-0" id="tablesListTable">
                        <thead class="table-light">
                            <tr>
                                <th style="width: 70px;">STT</th>
                                <th>Mã Bàn</th>
                                <th>Tên Bàn</th>
                                <th>Mã QR Code</th>
                                <th class="text-center" style="width: 140px;">Hành Động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="table" items="${tables}" varStatus="status">
                                <tr>
                                    <td class="fw-bold text-muted">${status.index + 1}</td>
                                    <td>
                                        <span class="badge bg-light text-dark border">#${table.maBan}</span>
                                    </td>
                                    <td>
                                        <strong class="text-dark fs-6">📍 ${table.tenBan}</strong>
                                    </td>
                                    <td>
                                        <div class="d-flex align-items-center gap-1">
                                            <code class="text-primary font-monospace fs-7 bg-primary bg-opacity-10 px-2 py-1 rounded">
                                                ${not empty table.maCodeQR ? table.maCodeQR : 'TABLE_' + table.maBan}
                                            </code>
                                            <button type="button" class="btn btn-sm btn-outline-primary fw-semibold px-2 py-1 rounded-2 shadow-2xs ms-1" 
                                                    onclick="openQRModal(${table.maBan}, '${table.tenBan}', '${not empty table.maCodeQR ? table.maCodeQR : 'TABLE_' + table.maBan}')">
                                                <i class="bi bi-qr-code-scan me-1"></i> Xem QR
                                            </button>
                                        </div>
                                    </td>

                                    <td class="text-center">
                                        <div class="btn-group btn-group-sm">
                                            <a href="${pageContext.request.contextPath}/admin/tables?action=edit&id=${table.maBan}" 
                                               class="btn btn-outline-warning text-dark px-2.5" title="Chỉnh sửa">
                                                <i class="bi bi-pencil-square"></i> Sửa
                                            </a>
                                            <button type="button" class="btn btn-outline-danger px-2.5" title="Xóa bàn"
                                                    onclick="confirmDeleteTable(${table.maBan}, '${table.tenBan}')">
                                                <i class="bi bi-trash"></i> Xóa
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Modal Xác Nhận Xóa Bàn -->
<div class="modal fade" id="deleteTableModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg rounded-4">
            <div class="modal-header border-0 bg-danger bg-opacity-10 py-3">
                <h5 class="modal-title fw-bold text-danger">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i>Xác Nhận Xóa Bàn
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body p-4 text-center">
                <p class="fs-6 text-muted mb-2">Bạn có chắc chắn muốn xóa bàn ăn này khỏi hệ thống?</p>
                <h4 class="fw-bold text-dark mb-3" id="deleteTableName"></h4>
                <small class="text-danger d-block">
                    <i class="bi bi-info-circle me-1"></i>Lưu ý: Nếu bàn này đã có đơn hàng liên quan, hệ thống sẽ ngăn việc xóa để đảm bảo toàn vẹn dữ liệu.
                </small>
            </div>
            <div class="modal-footer border-0 bg-light p-3 justify-content-end">
                <button type="button" class="btn btn-outline-secondary px-4 rounded-pill" data-bs-dismiss="modal">Hủy bỏ</button>
                <a href="#" id="confirmDeleteTableBtn" class="btn btn-danger px-4 rounded-pill fw-bold">Xác Nhận Xóa</a>
            </div>
        </div>
    </div>
</div>

<!-- Modal Xem & In Mã QR Code Bàn -->
<div class="modal fade" id="viewQRCodeModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg rounded-4 overflow-hidden">
            <div class="modal-header border-0 bg-primary bg-opacity-10 py-3">
                <h5 class="modal-title fw-bold text-primary d-flex align-items-center">
                    <i class="bi bi-qr-code-scan me-2 fs-4"></i>
                    Mã QR Code Vị Trí Bàn
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body p-4 text-center">
                <div class="badge bg-primary-subtle text-primary border border-primary px-3 py-1.5 fs-6 rounded-pill mb-3" id="qrModalTableNameBadge">
                    📍 Bàn
                </div>
                
                <div class="p-3 bg-white rounded-4 shadow-sm border border-secondary border-opacity-10 d-inline-block mb-3">
                    <img id="qrModalImage" src="" alt="Mã QR Bàn" class="img-fluid rounded" style="width: 220px; height: 220px; object-fit: contain;">
                </div>

                <div class="alert alert-light border text-start p-3 rounded-3 mb-0">
                    <small class="text-muted d-block fw-bold mb-1">Mã QR Code:</small>
                    <code class="text-primary font-monospace fs-6 d-block mb-2" id="qrModalCodeText">TABLE_01</code>
                    <small class="text-muted d-block fw-bold mb-1">Đường dẫn quét tự động:</small>
                    <input type="text" id="qrModalFullUrl" class="form-control form-control-sm bg-white font-monospace text-muted" readonly>
                </div>
            </div>
            <div class="modal-footer border-0 bg-light p-3 justify-content-between">
                <button type="button" class="btn btn-outline-secondary fw-semibold rounded-pill px-3" data-bs-dismiss="modal">Đóng</button>
                <div class="d-flex gap-2">
                    <a id="qrModalDownloadBtn" href="#" download="qr-code.png" class="btn btn-outline-primary fw-semibold rounded-pill px-3" target="_blank">
                        <i class="bi bi-download me-1"></i> Tải Ảnh QR
                    </a>
                    <button type="button" class="btn btn-primary fw-bold rounded-pill px-3 shadow-sm" onclick="printQRCodeCard()">
                        <i class="bi bi-printer-fill me-1"></i> In Mã QR (Dán Bàn)
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    let currentQRTableData = { id: 0, name: '', qr: '', url: '' };

    function openQRModal(id, name, qrCode) {
        currentQRTableData.id = id;
        currentQRTableData.name = name;
        currentQRTableData.qr = qrCode;

        // Xây dựng URL động cho mã QR
        const protocol = window.location.protocol;
        const host = window.location.host;
        const contextPath = '${pageContext.request.contextPath}';
        const fullMenuUrl = protocol + '//' + host + contextPath + '/menu?tableId=' + id;
        currentQRTableData.url = fullMenuUrl;

        // Sinh link ảnh mã QR từ API QRServer
        const qrImgUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=' + encodeURIComponent(fullMenuUrl);

        document.getElementById('qrModalTableNameBadge').innerHTML = '📍 ' + name;
        document.getElementById('qrModalCodeText').innerText = qrCode;
        document.getElementById('qrModalFullUrl').value = fullMenuUrl;
        document.getElementById('qrModalImage').src = qrImgUrl;
        document.getElementById('qrModalDownloadBtn').href = qrImgUrl;

        const modal = new bootstrap.Modal(document.getElementById('viewQRCodeModal'));
        modal.show();
    }

    function printQRCodeCard() {
        const qrImgUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=' + encodeURIComponent(currentQRTableData.url);
        const printWindow = window.open('', '_blank', 'width=550,height=650');
        printWindow.document.write(`
            <!DOCTYPE html>
            <html>
            <head>
                <title>In Mã QR - \${currentQRTableData.name}</title>
                <style>
                    body { font-family: system-ui, sans-serif; text-align: center; padding: 40px 20px; background: #fff; }
                    .qr-card { border: 3px solid #00704A; border-radius: 20px; padding: 30px; max-width: 380px; margin: 0 auto; box-shadow: 0 10px 25px rgba(0,0,0,0.1); }
                    .brand { color: #00704A; font-size: 24px; font-weight: bold; margin-bottom: 5px; }
                    .sub { color: #666; font-size: 13px; margin-bottom: 20px; }
                    .table-title { background: #00704A; color: #fff; font-size: 22px; font-weight: bold; padding: 8px 20px; border-radius: 50px; display: inline-block; margin-bottom: 20px; }
                    .qr-img { width: 220px; height: 220px; margin-bottom: 15px; }
                    .instruction { font-size: 13px; color: #333; font-weight: bold; line-height: 1.4; }
                </style>
            </head>
            <body>
                <div class="qr-card">
                    <div class="brand">QRCoffeePoly</div>
                    <div class="sub">Hệ Thống Đặt Món Thông Minh</div>
                    <div class="table-title">📍 \${currentQRTableData.name}</div>
                    <div><img src="\${qrImgUrl}" class="qr-img" /></div>
                    <div class="instruction">Quét mã QR bằng Camera điện thoại<br>để xem Thực Đơn & Đặt Món tận bàn</div>
                </div>
                <script>
                    window.onload = function() {
                        setTimeout(function() { window.print(); window.close(); }, 500);
                    };
                <\/script>
            </body>
            </html>
        `);
        printWindow.document.close();
    }

    function confirmDeleteTable(id, name) {
        document.getElementById('deleteTableName').innerText = name;
        document.getElementById('confirmDeleteTableBtn').href = '${pageContext.request.contextPath}/admin/tables?action=delete&id=' + id;
        const modal = new bootstrap.Modal(document.getElementById('deleteTableModal'));
        modal.show();
    }

    function filterTables() {
        const input = document.getElementById("searchTableInput");
        const filter = input.value.toLowerCase();
        const table = document.getElementById("tablesListTable");
        const tr = table.getElementsByTagName("tr");

        for (let i = 1; i < tr.length; i++) {
            const tdName = tr[i].getElementsByTagName("td")[2];
            const tdQR = tr[i].getElementsByTagName("td")[3];
            if (tdName || tdQR) {
                const txtName = tdName ? tdName.textContent || tdName.innerText : "";
                const txtQR = tdQR ? tdQR.textContent || tdQR.innerText : "";
                if (txtName.toLowerCase().indexOf(filter) > -1 || txtQR.toLowerCase().indexOf(filter) > -1) {
                    tr[i].style.display = "";
                } else {
                    tr[i].style.display = "none";
                }
            }
        }
    }
</script>

<jsp:include page="common/footer.jsp" />
