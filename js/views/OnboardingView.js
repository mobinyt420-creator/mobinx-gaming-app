import { authService } from '../services/authService.js';
import { stateManager } from '../services/stateManager.js';
import { Toast } from '../components/Toast.js';

let onboardStep = 2; // Step 1: Welcome Splash, Step 2: Google Email, Step 3: Name & Phone
let tempEmail = '';
let hasAutoSkippedSplash = false;

export function renderOnboardingView() {
  return `
    <div class="view-container onboarding-view" style="min-height: 100%; background: #080c14; color: #ffffff; padding: 32px 20px 24px 20px; display: flex; flex-direction: column; justify-content: space-between; overflow-y: auto;">
      
      <!-- Top Branding -->
      <div style="display: flex; flex-direction: column; align-items: center; text-align: center; margin-top: 20px;">
        <div style="width: 76px; height: 76px; border-radius: 22px; background: linear-gradient(135deg, #0284c7 0%, #2563eb 100%); display: flex; align-items: center; justify-content: center; box-shadow: 0 10px 30px rgba(37, 99, 235, 0.4); margin-bottom: 14px; border: 2px solid rgba(56, 189, 248, 0.3);">
          <svg width="44" height="44" viewBox="0 0 24 24" fill="none">
            <path d="M4 5L12 13L20 5V19H16V10L12 14L8 10V19H4V5Z" fill="#ffffff"/>
          </svg>
        </div>

        <div style="display: inline-block; background: rgba(56, 189, 248, 0.15); color: #38bdf8; border: 1px solid rgba(56, 189, 248, 0.3); padding: 3px 14px; border-radius: 20px; font-size: 11px; font-weight: 800; letter-spacing: 0.5px; margin-bottom: 8px;">
          MOBIN X GAMING ECOSYSTEM
        </div>

        <h1 style="font-size: 24px; font-weight: 900; color: #ffffff; margin: 0 0 6px 0; font-family: var(--font-heading);">
          ${onboardStep === 2 ? 'Sign In with Google' : (onboardStep === 3 ? 'Player Profile' : 'Welcome to Mobin X')}
        </h1>
        <p style="font-size: 13px; color: #94a3b8; margin: 0; max-width: 300px; line-height: 1.4;">
          ${onboardStep === 2 ? 'Continue with your Gmail to connect to cloud services.' : 'Enter your name and phone number to complete setup.'}
        </p>
      </div>

      <!-- Main Step Container -->
      <div style="background: #0f172a; border: 1.5px solid rgba(255, 255, 255, 0.08); border-radius: 20px; padding: 22px 18px; box-shadow: 0 16px 40px rgba(0, 0, 0, 0.5); margin: 24px 0;">
        
        ${onboardStep === 2 ? `
          <!-- STEP 2: Google Sign In -->
          <div style="display: flex; flex-direction: column; gap: 16px;">
            <div style="text-align: center; font-size: 12px; color: #64748b; font-weight: 600;">
              Step 1 of 2: Gmail Authentication
            </div>

            <!-- 1-Tap Google Button -->
            <button id="btn-google-tap-select" style="width: 100%; padding: 13px 16px; background: #ffffff; border: none; border-radius: 12px; font-size: 14px; font-weight: 800; color: #0f172a; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 10px; box-shadow: 0 4px 14px rgba(0,0,0,0.25);">
              <svg width="20" height="20" viewBox="0 0 24 24">
                <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"/>
                <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"/>
              </svg>
              <span>Continue with Google</span>
            </button>

            <div style="display: flex; align-items: center; gap: 8px; margin: 4px 0;">
              <div style="flex: 1; height: 1px; background: rgba(255,255,255,0.08);"></div>
              <span style="font-size: 11px; color: #64748b; font-weight: 600;">or confirm your Gmail</span>
              <div style="flex: 1; height: 1px; background: rgba(255,255,255,0.08);"></div>
            </div>

            <div>
              <label style="font-size: 12px; font-weight: 700; color: #cbd5e1;">Your Gmail Address *</label>
              <input type="email" id="input-onboard-email" placeholder="e.g. yourname@gmail.com" value="${tempEmail || ''}" style="width: 100%; padding: 12px; background: #080c14; border: 1.5px solid #1e293b; border-radius: 10px; font-size: 13.5px; color: #ffffff; outline: none; margin-top: 6px; font-weight: 600;" required />
            </div>

            <button id="btn-next-step" style="width: 100%; padding: 13px; background: linear-gradient(135deg, #0284c7 0%, #2563eb 100%); color: #ffffff; border: none; border-radius: 10px; font-size: 14px; font-weight: 800; cursor: pointer; box-shadow: 0 4px 14px rgba(37, 99, 235, 0.35); margin-top: 4px;">
              Next: Enter Name & Phone →
            </button>
          </div>
        ` : `
          <!-- STEP 3: Name & Phone Registration -->
          <div style="display: flex; flex-direction: column; gap: 14px;">
            <div style="display: flex; justify-content: space-between; align-items: center; font-size: 12px; color: #64748b; font-weight: 600;">
              <span>Step 2 of 2: Final Details</span>
              <button id="btn-back-to-step2" style="background: transparent; border: none; color: #38bdf8; font-size: 11.5px; cursor: pointer; font-weight: 700;">
                ← Change Gmail (${tempEmail})
              </button>
            </div>

            <div>
              <label style="font-size: 12px; font-weight: 700; color: #cbd5e1;">Full Name / Gamer Tag *</label>
              <input type="text" id="input-onboard-name" placeholder="Enter your in-game name" style="width: 100%; padding: 11px 12px; background: #080c14; border: 1.5px solid #1e293b; border-radius: 10px; font-size: 13px; color: #ffffff; outline: none; margin-top: 4px; font-weight: 600;" required />
            </div>

            <div>
              <label style="font-size: 12px; font-weight: 700; color: #cbd5e1;">Phone Number (bKash / Personal) *</label>
              <input type="tel" id="input-onboard-phone" placeholder="Enter 11-digit phone (01XXXXXXXXX)" style="width: 100%; padding: 11px 12px; background: #080c14; border: 1.5px solid #1e293b; border-radius: 10px; font-size: 13px; color: #ffffff; outline: none; margin-top: 4px; font-weight: 600;" required />
            </div>

            <div>
              <label style="font-size: 12px; font-weight: 700; color: #cbd5e1;">Free Fire UID (Optional)</label>
              <input type="text" id="input-onboard-uid" placeholder="UID (e.g. 198273918)" style="width: 100%; padding: 11px 12px; background: #080c14; border: 1.5px solid #1e293b; border-radius: 10px; font-size: 13px; color: #ffffff; outline: none; margin-top: 4px; font-weight: 600;" />
            </div>

            <button id="btn-onboard-complete" style="width: 100%; padding: 13px; background: linear-gradient(135deg, #10b981 0%, #059669 100%); color: #ffffff; border: none; border-radius: 10px; font-size: 14px; font-weight: 800; cursor: pointer; box-shadow: 0 4px 14px rgba(16, 185, 129, 0.35); margin-top: 6px;">
              Complete Registration & Enter App 🚀
            </button>
          </div>
        `}

        <!-- Guest Access Option -->
        <div style="text-align: center; margin-top: 16px;">
          <button id="btn-onboard-guest" style="background: transparent; border: none; font-size: 11.5px; color: #64748b; cursor: pointer; font-weight: 600; text-decoration: underline;">
            Continue as Guest (Explore Features)
          </button>
        </div>

      </div>

      <!-- Trust Footer -->
      <div style="display: flex; justify-content: center; align-items: center; gap: 14px; font-size: 11px; color: #64748b;">
        <span>🔒 256-bit Secure</span>
        <span>•</span>
        <span>⚡ Real-Time Cloud</span>
        <span>•</span>
        <span>🛡️ Anti-Ban</span>
      </div>

    </div>
  `;
}

export function bindOnboardingEvents() {
  // Step 2: Continue with Google tap
  document.getElementById('btn-google-tap-select')?.addEventListener('click', () => {
    const emailInput = document.getElementById('input-onboard-email');
    if (emailInput && !emailInput.value) {
      emailInput.focus();
      emailInput.style.borderColor = '#38bdf8';
    }
  });

  // Step 2 -> Step 3
  document.getElementById('btn-next-step')?.addEventListener('click', () => {
    const email = document.getElementById('input-onboard-email')?.value?.trim();
    if (!email || !email.includes('@')) {
      Toast.show('Please enter a valid Gmail address', 'warning');
      return;
    }
    tempEmail = email;
    onboardStep = 3;
    stateManager.navigate('onboarding');
  });

  // Step 3 -> Step 2 (Change email)
  document.getElementById('btn-back-to-step2')?.addEventListener('click', () => {
    onboardStep = 2;
    stateManager.navigate('onboarding');
  });

  // Step 3: Complete Registration
  document.getElementById('btn-onboard-complete')?.addEventListener('click', async () => {
    const name = document.getElementById('input-onboard-name')?.value?.trim();
    const phone = document.getElementById('input-onboard-phone')?.value?.trim();
    const ffUid = document.getElementById('input-onboard-uid')?.value?.trim();

    if (!name) {
      Toast.show('Please enter your Name / Gamer Tag', 'warning');
      return;
    }
    if (!phone || phone.length < 8) {
      Toast.show('Please enter a valid Phone number', 'warning');
      return;
    }

    const user = await authService.loginWithGoogle(tempEmail, name, phone, ffUid);
    authService.setOnboardingCompleted(true);
    Toast.show(`Welcome, ${user.fullName}! User ID: ${user.id}`, 'success');
    stateManager.navigate('home');
  });

  // Guest Skip
  document.getElementById('btn-onboard-guest')?.addEventListener('click', () => {
    authService.setOnboardingCompleted(true);
    Toast.show('Welcome to Mobin X! Exploring as Guest.', 'info');
    stateManager.navigate('home');
  });
}
