import { authService } from '../services/authService.js';
import { stateManager } from '../services/stateManager.js';
import { Toast } from '../components/Toast.js';

let activeAuthTab = 'google'; // 'google' | 'phone'

export function renderOnboardingView() {
  return `
    <div class="view-container onboarding-view" style="min-height: 100%; background: #ffffff; color: #0f172a; padding: 32px 20px 24px 20px; display: flex; flex-direction: column; justify-content: space-between; overflow-y: auto;">
      
      <!-- Top Clean Welcoming Branding -->
      <div style="display: flex; flex-direction: column; align-items: center; text-align: center; margin-top: 10px;">
        
        <!-- App Brand Logo Icon -->
        <div style="width: 76px; height: 76px; border-radius: 22px; background: linear-gradient(135deg, #0284c7 0%, #2563eb 100%); display: flex; align-items: center; justify-content: center; box-shadow: 0 10px 25px rgba(2, 132, 199, 0.25); margin-bottom: 14px;">
          <svg width="42" height="42" viewBox="0 0 24 24" fill="none">
            <path d="M4 5L12 13L20 5V19H16V10L12 14L8 10V19H4V5Z" fill="#ffffff"/>
          </svg>
        </div>

        <div style="display: inline-block; background: #e0f2fe; color: #0284c7; padding: 4px 12px; border-radius: 20px; font-size: 11px; font-weight: 800; letter-spacing: 0.5px; margin-bottom: 6px;">
          ⚡ THE GAMING ECOSYSTEM
        </div>

        <h1 style="font-size: 26px; font-weight: 900; color: #0f172a; letter-spacing: -0.5px; margin: 0 0 6px 0; font-family: var(--font-heading);">
          Welcome to Mobin X
        </h1>
        <p style="font-size: 13px; color: #64748b; margin: 0; max-width: 300px; line-height: 1.4;">
          Your official hub for instant diamond top-ups, daily esports tournaments & custom sensitivity tools.
        </p>
      </div>

      <!-- Authentication Card (Clean White with Soft Shadow) -->
      <div style="background: #ffffff; border: 1px solid #e2e8f0; border-radius: 20px; padding: 20px 18px; box-shadow: 0 10px 30px rgba(0, 0, 0, 0.06); margin: 24px 0;">
        
        <!-- Auth Mode Switcher -->
        <div style="display: flex; background: #f1f5f9; padding: 4px; border-radius: 12px; margin-bottom: 16px; gap: 4px;">
          <button id="tab-auth-google" style="flex: 1; padding: 8px; border-radius: 9px; font-size: 12px; font-weight: 800; border: none; cursor: pointer; transition: all 0.2s ease; ${activeAuthTab === 'google' ? 'background: #ffffff; color: #0284c7; box-shadow: 0 2px 6px rgba(0,0,0,0.06);' : 'background: transparent; color: #64748b;'}">
            Continue with Google
          </button>
          <button id="tab-auth-phone" style="flex: 1; padding: 8px; border-radius: 9px; font-size: 12px; font-weight: 800; border: none; cursor: pointer; transition: all 0.2s ease; ${activeAuthTab === 'phone' ? 'background: #ffffff; color: #0284c7; box-shadow: 0 2px 6px rgba(0,0,0,0.06);' : 'background: transparent; color: #64748b;'}">
            Name & Phone
          </button>
        </div>

        ${activeAuthTab === 'google' ? `
          <!-- TAB 1: Google Form -->
          <div style="display: flex; flex-direction: column; gap: 12px;">
            
            <!-- Quick 1-Tap Google Button -->
            <button id="btn-onboard-continue-google" style="width: 100%; padding: 12px 16px; background: #ffffff; border: 1.5px solid #cbd5e1; border-radius: 12px; font-size: 13.5px; font-weight: 700; color: #1e293b; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 10px; box-shadow: 0 2px 6px rgba(0,0,0,0.04); transition: all 0.15s ease;">
              <svg width="20" height="20" viewBox="0 0 24 24">
                <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"/>
                <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"/>
              </svg>
              <span>Sign in with Google</span>
            </button>

            <div style="display: flex; align-items: center; gap: 8px; margin: 2px 0;">
              <div style="flex: 1; height: 1px; background: #e2e8f0;"></div>
              <span style="font-size: 11px; color: #94a3b8; font-weight: 600;">or customize gamer profile</span>
              <div style="flex: 1; height: 1px; background: #e2e8f0;"></div>
            </div>

            <div>
              <label style="font-size: 11.5px; font-weight: 700; color: #475569;">Gmail Address</label>
              <input type="email" id="onboard-google-email" placeholder="e.g. gamer@gmail.com" value="mobinyt420@gmail.com" style="width: 100%; padding: 9px 12px; border: 1.5px solid #cbd5e1; border-radius: 10px; font-size: 12.5px; outline: none; margin-top: 4px; font-weight: 600;" />
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 8px;">
              <div>
                <label style="font-size: 11.5px; font-weight: 700; color: #475569;">In-Game Tag</label>
                <input type="text" id="onboard-google-username" placeholder="Mobin_Admin" value="Mobin_Admin" style="width: 100%; padding: 9px 10px; border: 1.5px solid #cbd5e1; border-radius: 10px; font-size: 12px; outline: none; margin-top: 4px; font-weight: 600;" />
              </div>
              <div>
                <label style="font-size: 11.5px; font-weight: 700; color: #475569;">Free Fire UID</label>
                <input type="text" id="onboard-google-uid" placeholder="2894192841" value="2894192841" style="width: 100%; padding: 9px 10px; border: 1.5px solid #cbd5e1; border-radius: 10px; font-size: 12px; outline: none; margin-top: 4px; font-weight: 600;" />
              </div>
            </div>

            <button id="btn-onboard-continue-google-alt" style="width: 100%; padding: 11px; background: #0284c7; color: #ffffff; border: none; border-radius: 10px; font-size: 13px; font-weight: 800; cursor: pointer; box-shadow: 0 4px 12px rgba(2, 132, 199, 0.25);">
              Continue & Enter Mobin X →
            </button>
          </div>
        ` : `
          <!-- TAB 2: Phone Registration Form -->
          <div style="display: flex; flex-direction: column; gap: 11px;">
            <div>
              <label style="font-size: 11.5px; font-weight: 700; color: #475569;">Full Name *</label>
              <input type="text" id="onboard-phone-name" placeholder="e.g. Tanvir Hossain" value="Tanvir Hossain" style="width: 100%; padding: 9px 12px; border: 1.5px solid #cbd5e1; border-radius: 10px; font-size: 12.5px; outline: none; margin-top: 4px; font-weight: 600;" />
            </div>

            <div>
              <label style="font-size: 11.5px; font-weight: 700; color: #475569;">Phone Number (bKash / Nagad) *</label>
              <input type="tel" id="onboard-phone-number" placeholder="018XXXXXXXX" value="01812345678" style="width: 100%; padding: 9px 12px; border: 1.5px solid #cbd5e1; border-radius: 10px; font-size: 12.5px; outline: none; margin-top: 4px; font-weight: 600;" />
            </div>

            <div>
              <label style="font-size: 11.5px; font-weight: 700; color: #475569;">Free Fire UID (Player ID)</label>
              <input type="text" id="onboard-phone-uid" placeholder="e.g. 2894192841" value="2894192841" style="width: 100%; padding: 9px 12px; border: 1.5px solid #cbd5e1; border-radius: 10px; font-size: 12.5px; outline: none; margin-top: 4px; font-weight: 600;" />
            </div>

            <button id="btn-onboard-continue-phone" style="width: 100%; padding: 11px; background: #10b981; color: #ffffff; border: none; border-radius: 10px; font-size: 13px; font-weight: 800; cursor: pointer; box-shadow: 0 4px 12px rgba(16, 185, 129, 0.25); margin-top: 4px;">
              Complete Registration & Enter →
            </button>
          </div>
        `}

        <!-- Skip / Guest Option -->
        <div style="text-align: center; border-top: 1px solid #f1f5f9; padding-top: 12px; margin-top: 12px;">
          <button id="btn-onboard-guest" style="background: none; border: none; font-size: 12px; font-weight: 700; color: #64748b; cursor: pointer; padding: 4px 8px; text-decoration: underline;">
            Skip & Explore as Guest →
          </button>
        </div>
      </div>

      <!-- Clean Trust Badges Footer -->
      <div style="display: flex; justify-content: center; align-items: center; gap: 14px; font-size: 11px; color: #94a3b8;">
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

  document.getElementById('tab-auth-phone')?.addEventListener('click', () => {
    activeAuthTab = 'phone';
    stateManager.navigate('onboarding');
  });

  // Google Login / Registration with Firebase Auth Integration
  const handleGoogleAuth = async () => {
    try {
      const { signInWithGoogleFirebase } = await import('../services/firebaseService.js');
      const googleUser = await signInWithGoogleFirebase();
      if (googleUser && googleUser.email) {
        const user = authService.loginWithGoogle(googleUser.email, googleUser.displayName, {
          avatar: googleUser.photoURL,
          ffUid: document.getElementById('onboard-google-uid')?.value || '2894192841'
        });
        Toast.show(`Welcome, ${user.username}! Signed in with Google.`, 'success');
        stateManager.navigate('home');
        return;
      }
    } catch (err) {
      console.log('Firebase auth notice:', err?.message);
    }

    // Direct input fallback
    const email = document.getElementById('onboard-google-email')?.value || 'mobinyt420@gmail.com';
    const username = document.getElementById('onboard-google-username')?.value || 'Mobin_Admin';
    const ffUid = document.getElementById('onboard-google-uid')?.value || '2894192841';

    const user = authService.loginWithGoogle(email, username, { ffUid });
    Toast.show(`Welcome, ${user.username}! Account initialized.`, 'success');
    stateManager.navigate('home');
  };

  document.getElementById('btn-onboard-continue-google')?.addEventListener('click', handleGoogleAuth);
  document.getElementById('btn-onboard-continue-google-alt')?.addEventListener('click', handleGoogleAuth);

  // Phone Registration
  document.getElementById('btn-onboard-continue-phone')?.addEventListener('click', () => {
    const name = document.getElementById('onboard-phone-name')?.value;
    const phone = document.getElementById('onboard-phone-number')?.value;
    const ffUid = document.getElementById('onboard-phone-uid')?.value;

    if (!name || !phone) {
      Toast.show('Please provide Name and Phone number', 'warning');
      return;
    }

    const user = authService.loginWithPhone(name, phone, ffUid);
    Toast.show(`Welcome, ${user.fullName}! Registration completed.`, 'success');
    stateManager.navigate('home');
  });

  // Guest Skip
  document.getElementById('btn-onboard-guest')?.addEventListener('click', () => {
    authService.setOnboardingCompleted(true);
    Toast.show('Welcome to Mobin X! Exploring as Guest.', 'info');
    stateManager.navigate('home');
  });
}

