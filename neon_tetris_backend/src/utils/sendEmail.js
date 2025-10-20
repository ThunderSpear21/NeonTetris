import mailgun from 'mailgun.js';
import formData from 'form-data';

const mg = new mailgun(formData).client({
    username: 'api',
    key: process.env.MAILGUN_API_KEY,
});

export const sendEmail = async ({ to, subject, text }) => {
    if (!to || !subject || !text) {
        throw new Error("Missing required email fields");
    }

    const data = {
        from: `Neon Tetris <noreply@${process.env.MAILGUN_DOMAIN}>`,
        to: to,
        subject: subject,
        text: text,
    };

    try {
        console.log("Attempting to send email via Mailgun...");
        const response = await mg.messages.create(process.env.MAILGUN_DOMAIN, data);
        console.log("✅ Email sent successfully via Mailgun:", response);
    } catch (error) {
        console.error("❌ Mailgun sending error:", error);
        throw new Error("Failed to send OTP email.");
    }
};