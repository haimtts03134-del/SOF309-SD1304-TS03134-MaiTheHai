/**
 * Attendance Auto Notifier & Live Refresh Script (Ultra-Fast 1.5s Polling)
 * Tự động kiểm tra cập nhật bảng chấm công với tốc độ siêu nhanh (1.5s), phát âm thanh thông báo và làm mới dữ liệu tức thì cho cả Admin và Nhân viên.
 */
(function() {
    let lastHash = '';
    let isInitialFetch = true;
    let pollInterval = 1500; // 1.5s/lần
    let contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1)) || '';

    // Chỉ chạy script trên trang chấm công của Admin hoặc Nhân viên
    const path = window.location.pathname;
    if (!path.includes('/admin/attendance') && !path.includes('/staff/attendance')) {
        return;
    }

    // Khởi tạo Toast container
    function initToastContainer() {
        if (!document.getElementById('attendanceToastContainer')) {
            const container = document.createElement('div');
            container.id = 'attendanceToastContainer';
            container.className = 'toast-container position-fixed top-0 end-0 p-3';
            container.style.zIndex = '9999';
            document.body.appendChild(container);
        }
    }

    // Phát âm thanh thông báo "Ting-ting 🔔"
    function playChimeSound() {
        try {
            const AudioContext = window.AudioContext || window.webkitAudioContext;
            if (!AudioContext) return;
            const audioCtx = new AudioContext();
            
            const osc1 = audioCtx.createOscillator();
            const gain1 = audioCtx.createGain();
            osc1.type = 'sine';
            osc1.frequency.setValueAtTime(659.25, audioCtx.currentTime); // E5
            gain1.gain.setValueAtTime(0.3, audioCtx.currentTime);
            gain1.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.25);
            osc1.connect(gain1);
            gain1.connect(audioCtx.destination);
            osc1.start();
            osc1.stop(audioCtx.currentTime + 0.25);

            setTimeout(() => {
                const osc2 = audioCtx.createOscillator();
                const gain2 = audioCtx.createGain();
                osc2.type = 'sine';
                osc2.frequency.setValueAtTime(880, audioCtx.currentTime); // A5
                gain2.gain.setValueAtTime(0.4, audioCtx.currentTime);
                gain2.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.35);
                osc2.connect(gain2);
                gain2.connect(audioCtx.destination);
                osc2.start();
                osc2.stop(audioCtx.currentTime + 0.35);
            }, 100);
        } catch (e) {
            console.log('Audio autoplay prevented:', e);
        }
    }

    // Hiển thị thông báo Toast nổi
    function showNotificationToast() {
        initToastContainer();
        const container = document.getElementById('attendanceToastContainer');

        const toastId = 'toast-att-' + Date.now();
        const toastHTML = `
            <div id="${toastId}" class="toast align-items-center text-bg-warning border-0 shadow-lg mb-2" role="alert" aria-live="assertive" aria-atomic="true" style="border-radius: 12px; font-family: system-ui, sans-serif;">
                <div class="d-flex p-3">
                    <div class="fs-2 me-3 d-flex align-items-center">
                        <i class="bi bi-calendar-check-fill text-dark animate__animated animate__swing"></i>
                    </div>
                    <div class="toast-body p-0 flex-grow-1 text-dark">
                        <div class="fw-bold fs-6 mb-1">🔔 CÓ CẬP NHẬT CHẤM CÔNG MỚI!</div>
                        <div class="small fw-semibold">Bảng chấm công đã được tự động làm mới dữ liệu thời gian thực.</div>
                    </div>
                    <button type="button" class="btn-close me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
                </div>
            </div>
        `;

        container.insertAdjacentHTML('beforeend', toastHTML);
        const toastEl = document.getElementById(toastId);
        if (window.bootstrap && bootstrap.Toast) {
            const bsToast = new bootstrap.Toast(toastEl, { delay: 4000 });
            bsToast.show();
        }
    }

    // Hàm polling ngầm
    function pollAttendance() {
        const url = contextPath + '/api/attendance/poll?t=' + Date.now();

        fetch(url)
            .then(res => res.json())
            .then(data => {
                if (!data || !data.hash) return;

                if (isInitialFetch) {
                    lastHash = data.hash;
                    isInitialFetch = false;
                    return;
                }

                if (data.hash !== lastHash) {
                    lastHash = data.hash;
                    playChimeSound();
                    showNotificationToast();
                    setTimeout(() => {
                        window.location.reload();
                    }, 200);
                }
            })
            .catch(err => {
                // Ignore network error silently
            });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() {
            pollAttendance();
            setInterval(pollAttendance, pollInterval);
        });
    } else {
        pollAttendance();
        setInterval(pollAttendance, pollInterval);
    }
})();
