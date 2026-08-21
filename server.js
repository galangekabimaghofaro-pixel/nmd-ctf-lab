const express = require('express');
const cookieParser = require('cookie-parser');
const app = express();

app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use(cookieParser());

// PHASE 1: Reconnaissance Header Expose
app.use((req, res, next) => {
    res.setHeader('X-Powered-By', 'SCENARIO75{Node.js}');
    next();
});

// Hidden Robots.txt Path
app.get('/robots.txt', (req, res) => {
    res.type('text/plain');
    res.send("Disallow: /api/verify-mfa # SCENARIO75{/api/verify-mfa}\nDisallow: /dashboard # SCENARIO75{/dashboard}");
});

// Session Initialization & Landing Page
app.get('/', (req, res) => {
    if (!req.cookies.pre_mfa_session) {
        res.cookie('pre_mfa_session', 'pending_mfa_verification', { httpOnly: false }); // SCENARIO75{pre_mfa_session}, SCENARIO75{pending_mfa_verification}, SCENARIO75{False}
    }
    res.send(`
        <html>
        <!-- SCENARIO75{robots.txt} -->
        <body>
            <h1>Admin Feedback System</h1>
            <form action="/submit-feedback" method="POST">
                <textarea name="feedback" placeholder="Enter feedback"></textarea>
                <button type="submit">Submit</button>
            </form>
        </body>
        </html>
    `);
});

// PHASE 2: WAF & Feedback Endpoint
app.post('/submit-feedback', (req, res) => { // SCENARIO75{POST}
    const feedback = req.body.feedback || '';

    // WAF Logic blocking <script>
    if (feedback.includes('<script>')) {
        return res.status(403).send("WAF Blocked: SCENARIO75{403}");
    }

    res.send("Feedback submitted successfully!");
});

// Dummy MFA Endpoint
app.get('/api/verify-mfa', (req, res) => {
    res.send("MFA Endpoint");
});

// PHASE 3: Dashboard & MFA Bypass
app.get('/dashboard', (req, res) => { // SCENARIO75{/dashboard}
    const session = req.cookies.adm_sess || req.cookies.pre_mfa_session; // SCENARIO75{adm_sess}

    if (session) {
        return res.send(`
            <html>
            <body>
                <h1>Admin Dashboard</h1>
                <div class="xss-payload">
                    ${req.query.payload || 'SCENARIO75{xss-payload}'}
                </div>
                <p>Flag: SCENARIO75{RED_C00k13_MFA_Byp4ss_0wn3d}</p>
            </body>
            </html>
        `);
    }
    res.status(401).send("Unauthorized");
});

app.listen(3075, () => console.log('App running on port 3075'));
