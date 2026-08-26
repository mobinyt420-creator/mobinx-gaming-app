import { authService } from '../services/authService.js';
import { stateManager } from '../services/stateManager.js';
import { Toast } from '../components/Toast.js';

let activeAuthTab = 'google'; // 'google' | 'manual'

export function renderOnboardingView() {
  return `
    <div class="view-container onboarding-view" style="min-height: 100%; background: #0b1329; color: #ffffff; padding: 28px 18px 24px 18px; display: flex; flex-direction: column; justify-content: space-between; overflow-y: auto;">
      
      <!-- Top Clean Welcoming Branding -->
      <div style="display: flex; flex-direction: column; align-items: center; text-align: center; margin-top: 10px;">
        
        <!-- App Brand Logo Icon -->
        <div style="width: 72px; height: 72px; border-radius: 20px; background: linear-gradient(135deg, #0284c7 0%, #2563eb 100%); display: flex; align-items: center; justify-content: center; box-shadow: 0 10px 25px rgba(2, 132, 199, 0.35); margin-bottom: 12px; border: 2px solid rgba(255,255,255,0.15);">
          <svg width="40" height="40" viewBox="0 0 24 24" fill="none">
            <path d="M4 5L12 13L20 5V19H16V10L12 14L8 10V19H4V5Z" fill="#ffffff"/>
          </svg>
        </div>

        <div style="display: inline-block; background: rgba(56, 189, 248, 0.15); color: #38bdf8; border: 1px solid rgba(56, 189, 248, 0.3); padding: 3px 12px; border-radius: 20px; font-size: 11px; font-weight: 800; letter-spacing: 0.5px; margin-bottom: 6px;">
          ⚡ THE GAMING ECOSYSTEM
        </div>

        <h1 style="font-size: 24px; font-weight: 900; color: #ffffff; letter-spacing: -0.5px; margin: 0 0 6px 0; font-family: var(--font-heading);">
          Welcome to Mobin X
        </h1>
        <p style="font-size: 12.5px; color: #94a3b8; margin: 0; max-width: 320px; line-height: 1.4;">
          Instant Free Fire diamond top-up, daily custom room tournaments & pro sensitivity tools.
        </p>
      </div>

      <!-- Authentication Card (Medium Professional Theme) -->
      <div style="background: #131d38; border: 1px solid rgba(255, 255, 255, 0.08); border-radius: 18px; padding: 20px 18px; box-shadow: 0 12px 36px rgba(0, 0, 0, 0.4); margin: 20px 0;">
        
        <!-- Auth Mode Switcher -->
        <div style="display: flex; background: #0b1329; padding: 4px; border-radius: 12px; margin-bottom: 16px; gap: 4px; border: 1px solid rgba(255,255,255,0.06);">
          <button id="tab-auth-google" style="flex: 1; padding: 9px 6px; border-radius: 9px; font-size: 12px; font-weight: 800; border: none; cursor: pointer; transition: all 0.2s ease; ${activeAuthTab === 'google' ? 'background: #2563eb; color: #ffffff; box-shadow: 0 2px 8px rgba(37, 99, 235, 0.4);' : 'background: transparent; color: #94a3b8;'}">
            Continue with Google
          </button>
          <button id="tab-auth-manual" style="flex: 1; padding: 9px 6px; border-radius: 9px; font-size: 12px; font-weight: 800; border: none; cursor: pointer; transition: all 0.2s ease; ${activeAuthTab === 'manual' ? 'background: #2563eb; color: #ffffff; box-shadow: 0 2px 8px rgba(37, 99, 235, 0.4);' : 'background: transparent; color: #94a3b8;'}">
            Manual Registration
          </button>
        </div>

        ${activeAuthTab === 'google' ? `
          <!-- TAB 1: Google Form -->
          <div style="display: flex; flex-direction: column; gap: 12px;">
            
            <!-- Quick 1-Tap Google Button -->
            <button id="btn-onboard-continue-google" style="width: 100%; padding: 11px 16px; background: #ffffff; border: none; border-radius: 12px; font-size: 13.5px; font-weight: 700; color: #0f172a; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.2); transition: all 0.15s ease;">
              <svg width="18" height="18" viewBox="0 0 24 24">
                <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"/>
                <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"/>
              </svg>
              <span>1-Tap Google Sign In</span>
            </button>

            <div style="display: flex; align-items: center; gap: 8px; margin: 2px 0;">
              <div style="flex: 1; height: 1px; background: rgba(255,255,255,0.08);"></div>
              <span style="font-size: 11px; color: #64748b; font-weight: 600;">or enter details below</span>
              <div style="flex: 1; height: 1px; background: rgba(255,255,255,0.08);"></div>
            </div>

            <div>
              <label style="font-size: 11.5px; font-weight: 700; color: #cbd5e1;">Gmail Address *</label>
              <input type="email" id="onboard-google-email" placeholder="e.g. player@gmail.com" style="width: 100%; padding: 10px 12px; background: #0b1329; border: 1.5px solid #1e293b; border-radius: 10px; font-size: 13px; color: #ffffff; outline: none; margin-top: 4px; font-weight: 600;" required />
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 8px;">
              <div>
                <label style="font-size: 11.5px; font-weight: 700; color: #cbd5e1;">Name / IGN *</label>
                <input type="text" id="onboard-google-username" placeholder="Player Name" style="width: 100%; padding: 10px 10px; background: #0b1329; border: 1.5px solid #1e293b; border-radius: 10px; font-size: 12.5px; color: #ffffff; outline: none; margin-top: 4px; font-weight: 600;" required />
              </div>
              <div>
                <label style="font-size: 11.5px; font-weight: 700; color: #cbd5e1;">Phone Number *</label>
                <input type="tel" id="onboard-google-phone" placeholder="01XXXXXXXXX" style="width: 100%; padding: 10px 10px; background: #0b1329; border: 1.5px solid #1e293b; border-radius: 10px; font-size: 12.5px; color: #ffffff; outline: none; margin-top: 4px; font-weight: 600;" required />
              </div>
            </div>

            <div>
              <label style="font-size: 11.5px; font-weight: 700; color: #cbd5e1;">Free Fire UID (Optional)</label>
              <input type="text" id="onboard-google-uid" placeholder="Enter your 10-digit FF UID" style="width: 100%; padding: 10px 12px; background: #0b1329; border: 1.5px solid #1e293b; border-radius: 10px; font-size: 12.5px; color: #ffffff; outline: none; margin-top: 4px; font-weight: 600;" />
            </div>

            <button id="btn-onboard-submit-google" style="width: 100%; padding: 12px; background: linear-gradient(135deg, #0284c7 0%, #2563eb 100%); color: #ffffff; border: none; border-radius: 10px; font-size: 13.5px; font-weight: 800; cursor: pointer; box-shadow: 0 4px 14px rgba(2, 132, 199, 0.3); margin-top: 4px;">
              Complete Registration & Enter App →
            </button>
          </div>
        ` : `
          <!-- TAB 2: Manual Registration Form -->
          <div style="display: flex; flex-direction: column; gap: 12px;">
            <div>
              <label style="font-size: 11.5px; font-weight: 700; color: #cbd5e1;">Full Name / IGN *</label>
              <input type="text" id="onboard-manual-name" placeholder="Enter your in-game name" style="width: 100%; padding: 10px 12px; background: #0b1329; border: 1.5px solid #1e293b; border-radius: 10px; font-size: 13px; color: #ffffff; outline: none; margin-top: 4px; font-weight: 600;" required />
            </div>

            <div>
              <label style="font-size: 11.5px; font-weight: 700; color: #cbd5e1;">Gmail Address *</label>
              <input type="email" id="onboard-manual-email" placeholder="e.g. gamer@gmail.com" style="width: 100%; padding: 10px 12px; background: #0b1329; border: 1.5px solid #1e293b; border-radius: 10px; font-size: 13px; color: #ffffff; outline: none; margin-top: 4px; font-weight: 600;" required />
            </div>

            <div>
              <label style="font-size: 11.5px; font-weight: 700; color: #cbd5e1;">Phone Number (bKash / Nagad) *</label>
              <input type="tel" id="onboard-manual-phone" placeholder="Enter 11-digit phone (01XXXXXXXXX)" style="width: 100%; padding: 10px 12px; background: #0b1329; border: 1.5px solid #1e293b; border-radius: 10px; font-size: 13px; color: #ffffff; outline: none; margin-top: 4px; font-weight: 600;" required />
            </div>

            <div>
              <label style="font-size: 11.5px; font-weight: 700; color: #cbd5e1;">Free Fire UID (Optional)</label>
              <input type="text" id="onboard-manual-uid" placeholder="UID (e.g. 198273918)" style="width: 100%; padding: 10px 12px; background: #0b1329; border: 1.5px solid #1e293b; border-radius: 10px; font-size: 13px; color: #ffffff; outline: none; margin-top: 4px; font-weight: 600;" />
            </div>

            <button id="btn-onboard-submit-manual" style="width: 100%; padding: 12px; background: linear-gradient(135deg, #10b981 0%, #059669 100%); color: #ffffff; border: none; border-radius: 10px; font-size: 13.5px; font-weight: 800; cursor: pointer; box-shadow: 0 4px 14px rgba(16, 185, 129, 0.3); margin-top: 4px;">
              Create Player Account →
            </button>
          </div>
        `}

        <!-- Guest Access Option -->
        <div style="text-align: center; margin-top: 14px;">
          <button id="btn-onboard-guest" style="background: transparent; border: none; font-size: 11.5px; color: #64748b; cursor: pointer; font-weight: 600; text-decoration: underline;">
            Continue as Guest (Explore Features)
          </button>
        </div>

      </div>

      <!-- Trust Footer -->
      <div style="display: flex; justify-content: center; align-items: center; gap: 14px; font-size: 11px; color: #64748b;">
        <span>🔒 256-bit Secure</span>
        <span>•</span>
        <span>⚡ 100% Automated</span>
        <span>•</span>
        <span>🛡️ Anti-Ban</span>
      </div>

    </div>
  `;
}

export function bindOnboardingEvents() {
  // Tab Switchers
  document.getElementById('tab-auth-google')?.addEventListener('click', () => {
    activeAuthTab = 'google';
    stateManager.navigate('onboarding');
  });

  document.getElementById('tab-auth-manual')?.addEventListener('click', () => {
    activeAuthTab = 'manual';
    stateManager.navigate('onboarding');
  });

  // 1-Tap Google Sign In using Firebase Auth
  document.getElementById('btn-onboard-continue-google')?.addEventListener('click', async () => {
    try {
      const { signInWithGoogleFirebase } = await import('../services/firebaseService.js');
      const googleUser = await signInWithGoogleFirebase();
      if (googleUser && googleUser.email) {
        document.getElementById('onboard-google-email').value = googleUser.email;
        if (googleUser.displayName) document.getElementById('onboard-google-username').value = googleUser.displayName;
        Toast.show('Google Account connected! Please confirm your phone number below.', 'success');
        return;
      }
    } catch (err) {
      console.log('Firebase popup note:', err?.message);
    }
    Toast.show('Please fill in your details below to continue', 'info');
  });

  // Submit Google Tab
  document.getElementById('btn-onboard-submit-google')?.addEventListener('click', async () => {
    const email = document.getElementById('onboard-google-email')?.value?.trim();
    const name = document.getElementById('onboard-google-username')?.value?.trim();
    const phone = document.getElementById('onboard-google-phone')?.value?.trim();
    const ffUid = document.getElementById('onboard-google-uid')?.value?.trim();

    if (!email) {
      Toast.show('Please enter your Gmail address', 'warning');
      return;
    }
    if (!name) {
      Toast.show('Please enter your Name / IGN', 'warning');
      return;
    }
    if (!phone) {
      Toast.show('Please enter your Phone number', 'warning');
      return;
    }

    const user = await authService.loginWithGoogle(email, name, phone, ffUid);
    authService.setOnboardingCompleted(true);
    Toast.show(`Welcome, ${user.fullName}! User ID: ${user.id}`, 'success');
    stateManager.navigate('home');
  });

  // Submit Manual Tab
  document.getElementById('btn-onboard-submit-manual')?.addEventListener('click', async () => {
    const name = document.getElementById('onboard-manual-name')?.value?.trim();
    const email = document.getElementById('onboard-manual-email')?.value?.trim();
    const phone = document.getElementById('onboard-manual-phone')?.value?.trim();
    const ffUid = document.getElementById('onboard-manual-uid')?.value?.trim();

    if (!name) {
      Toast.show('Please enter your Full Name', 'warning');
      return;
    }
    if (!email) {
      Toast.show('Please enter your Gmail address', 'warning');
      return;
    }
    if (!phone) {
      Toast.show('Please enter your Phone number', 'warning');
      return;
    }

    const user = await authService.loginWithGoogle(email, name, phone, ffUid);
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
