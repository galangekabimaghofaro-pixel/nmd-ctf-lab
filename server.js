const express = require('express');
const cookieParser = require('cookie-parser');
const app = express();

app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use(cookieParser());

// FASE 1: Header Rekondisi
app.use((req, res, next) => {
    res.setHeader('X-Powered-By', 'SCENARIO75{Node.js}');
    next();
});

// Path tersembunyi robots.txt
app.get('/robots.txt', (req, res) => {
    res.type('text/plain');
    res.send("Disallow: /api/verify-mfa # SCENARIO75{/api/verify-mfa}\nDisallow: /dashboard # SCENARIO75{/dashboard}");
});

// Inisialisasi Sesi Awal
app.get('/', (req, res) => {
    if (!req.cookies.pre_mfa_session) {
        res.cookie('pre_mfa_session', 'pending_mfa_verification', { httpOnly: false });
    }
    res.send(`
        <html>
        <!-- SCENARIO75{robots.txt} -->
        <body>
            <h1>Admin Feedback System</h1>
            <form action="/feedback" method="POST">
                <textarea name="feedback" placeholder="Tulis feedback..."></textarea>
                <button type="submit">Kirim</button>
            </form>
        </body>
        </html>
    `);
});

// FASE 2: WAF & Endpoint Feedback
app.post('/feedback', (req, res) => {
    const feedback = req.body.feedback || '';

    if (feedback.includes('<script>')) {
        console.error("[ERROR] 18:50:15 WAF Blocked <script> tag injection attempt from 10.10.14.50");
        return res.status(403).send("WAF Blocked: SCENARIO75{403}");
    }

    res.send("Feedback berhasil dikirim!");
});

// FASE 3: Bypass MFA & Dashboard
app.get('/dashboard', (req, res) => {
    const session = req.cookies.adm_sess || req.cookies.pre_mfa_session;

    if (session === 'pending_mfa_verification' || (session && session.startsWith('adm_sess'))) {
        return res.send(`
            <html>
            <body>
                <div class="xss-payload">
                    ${req.query.payload || 'Selamat Datang Admin'}
                </div>
                <p>Flag Akhir: SCENARIO75{RED_C00k13_MFA_Byp4ss_0wn3d}</p>
            </body>
            </html>
        `);
    }
    res.status(401).send("Unauthorized");
});

app.listen(3075, () => console.log('Server berjalan pada port 3075'));
