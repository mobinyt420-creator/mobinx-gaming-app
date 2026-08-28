import { authService } from '../services/authService.js';
import { stateManager } from '../services/stateManager.js';
import { firebaseService } from '../services/firebaseService.js';
import { Toast } from '../components/Toast.js';
import { openExternalStore } from '../services/browserService.js';

// Active View Modes: 'welcome' | 'google-setup'
let activeAuthMode = 'welcome';

export function renderOnboardingView() {
  if (activeAuthMode === 'google-setup') {
    return renderGoogleProfileSetupView();
  }
  return renderWelcomeStep();
}

/**
 * Screen 1: Welcome to Mobin X
 */
function renderWelcomeStep() {
  return `
    <div class="view-container onboarding-view onboarding-step-1" style="min-height: 100%; height: 100%; box-sizing: border-box; background: radial-gradient(circle at 50% 25%, #061e4f 0%, #030d24 60%, #010614 100%); color: #ffffff; padding: 24px 20px calc(24px + var(--safe-bottom)) 20px; display: flex; flex-direction: column; justify-content: space-between; overflow-y: auto;">
      
      <!-- Top Branding -->
      <div style="display: flex; flex-direction: column; align-items: center; text-align: center; margin-top: 6px;">
        <div style="width: 56px; height: 56px; border-radius: 16px; background: linear-gradient(135deg, #0284c7 0%, #2563eb 100%); display: flex; align-items: center; justify-content: center; box-shadow: 0 8px 24px rgba(37, 99, 235, 0.45); margin-bottom: 10px; border: 1.5px solid rgba(56, 189, 248, 0.4);">
          <img src="assets/images/mobinx_icon_512.png" alt="Mobin X" style="width: 46px; height: 46px; border-radius: 12px; object-fit: cover;" onerror="this.src='data:image/svg+xml;utf8,<svg xmlns=\\'http://www.w3.org/2000/svg\\' viewBox=\\'0 0 24 24\\' fill=\\'white\\'><path d=\\'M4 5L12 13L20 5V19H16V10L12 14L8 10V19H4V5Z\\'/></svg>';" />
        </div>

        <span style="font-size: 13.5px; font-weight: 600; color: #cbd5e1; letter-spacing: 0.2px;">Welcome to</span>
        <h1 style="font-size: 32px; font-weight: 900; color: #38bdf8; margin: 2px 0 4px 0; font-family: var(--font-heading); letter-spacing: -0.5px; text-shadow: 0 0 20px rgba(56, 189, 248, 0.4);">
          Mobin X
        </h1>
        <p style="font-size: 13px; color: #94a3b8; margin: 0; font-weight: 500;">
          Your Ultimate Gaming Hub
        </p>
      </div>

      <!-- Center 3D Controller Pedestal Art -->
      <div style="display: flex; justify-content: center; align-items: center; margin: 12px 0; position: relative;">
        <div style="position: absolute; width: 220px; height: 220px; background: radial-gradient(circle, rgba(2, 132, 199, 0.3) 0%, rgba(2, 132, 199, 0) 70%); border-radius: 50%; filter: blur(20px); pointer-events: none;"></div>
        <img 
          src="assets/images/onboarding_controller.jpg" 
          alt="Mobin X Gaming Controller" 
          style="width: 190px; height: 190px; object-fit: cover; border-radius: 26px; border: 1.5px solid rgba(56, 189, 248, 0.3); box-shadow: 0 12px 35px rgba(2, 132, 199, 0.35); position: relative; z-index: 2;"
        />
      </div>

      <!-- 3 Feature Highlight Cards -->
      <div style="display: flex; flex-direction: column; gap: 9px; margin-bottom: 16px;">
        
        <div style="background: rgba(15, 23, 42, 0.7); border: 1px solid rgba(56, 189, 248, 0.22); backdrop-filter: blur(10px); border-radius: 14px; padding: 10px 14px; display: flex; align-items: center; gap: 14px;">
          <div style="width: 38px; height: 38px; border-radius: 10px; background: rgba(56, 189, 248, 0.15); border: 1px solid rgba(56, 189, 248, 0.25); display: flex; align-items: center; justify-content: center; font-size: 19px; flex-shrink: 0;">
            💎
          </div>
          <div>
            <div style="font-size: 13.5px; font-weight: 800; color: #ffffff; letter-spacing: 0.2px;">Top Up & Diamonds</div>
            <div style="font-size: 11.5px; color: #94a3b8; font-weight: 500;">Fast & secure top up</div>
          </div>
        </div>

        <div style="background: rgba(15, 23, 42, 0.7); border: 1px solid rgba(245, 158, 11, 0.22); backdrop-filter: blur(10px); border-radius: 14px; padding: 10px 14px; display: flex; align-items: center; gap: 14px;">
          <div style="width: 38px; height: 38px; border-radius: 10px; background: rgba(245, 158, 11, 0.15); border: 1px solid rgba(245, 158, 11, 0.25); display: flex; align-items: center; justify-content: center; font-size: 19px; flex-shrink: 0;">
            🏆
          </div>
          <div>
            <div style="font-size: 13.5px; font-weight: 800; color: #ffffff; letter-spacing: 0.2px;">Tournaments</div>
            <div style="font-size: 11.5px; color: #94a3b8; font-weight: 500;">Join exciting battles</div>
          </div>
        </div>

        <div style="background: rgba(15, 23, 42, 0.7); border: 1px solid rgba(168, 85, 247, 0.22); backdrop-filter: blur(10px); border-radius: 14px; padding: 10px 14px; display: flex; align-items: center; gap: 14px;">
          <div style="width: 38px; height: 38px; border-radius: 10px; background: rgba(168, 85, 247, 0.15); border: 1px solid rgba(168, 85, 247, 0.25); display: flex; align-items: center; justify-content: center; font-size: 19px; flex-shrink: 0;">
            🎁
          </div>
          <div>
            <div style="font-size: 13.5px; font-weight: 800; color: #ffffff; letter-spacing: 0.2px;">Rewards & More</div>
            <div style="font-size: 11.5px; color: #94a3b8; font-weight: 500;">Win big, every day</div>
          </div>
        </div>

      </div>

      <!-- Bottom Action Button -->
      <div style="display: flex; flex-direction: column; gap: 10px; align-items: center; width: 100%;">
        <button id="btn-onboard-start" style="width: 100%; height: 52px; background: linear-gradient(135deg, #0066ff 0%, #0052cc 100%); color: #ffffff; border: none; border-radius: 14px; font-size: 15px; font-weight: 800; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 10px; box-shadow: 0 8px 24px rgba(0, 102, 255, 0.45); transition: transform 0.15s ease;">
          <span>Let's Get Started</span>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
            <line x1="5" y1="12" x2="19" y2="12"></line>
            <polyline points="12 5 19 12 12 19"></polyline>
          </svg>
        </button>
      </div>

    </div>
  `;
}

/**
 * Screen 2: Google Profile Setup (Clean, Premium, Direct)
 */
function renderGoogleProfileSetupView() {
  return `
    <div class="view-container onboarding-view onboarding-step-2" style="min-height: 100%; height: 100%; box-sizing: border-box; background: #f8fafc; color: #0f172a; padding: 22px 20px calc(24px + var(--safe-bottom)) 20px; display: flex; flex-direction: column; justify-content: space-between; overflow-y: auto; position: relative;">
      
      <!-- Ambient Glow -->
      <div style="position: absolute; top: -60px; left: 50%; transform: translateX(-50%); width: 280px; height: 180px; background: radial-gradient(circle, rgba(56, 189, 248, 0.18) 0%, rgba(56, 189, 248, 0) 70%); border-radius: 50%; pointer-events: none;"></div>

      <div style="position: relative; z-index: 2;">
        
        <!-- Header Branding -->
        <div style="display: flex; flex-direction: column; align-items: center; text-align: center; margin-bottom: 20px;">
          <div style="width: 54px; height: 54px; border-radius: 16px; background: linear-gradient(135deg, #0284c7 0%, #2563eb 100%); display: flex; align-items: center; justify-content: center; box-shadow: 0 8px 20px rgba(37, 99, 235, 0.35); margin-bottom: 8px;">
            <img src="assets/images/mobinx_icon_512.png" alt="Mobin X" style="width: 44px; height: 44px; border-radius: 12px; object-fit: cover;" onerror="this.src='data:image/svg+xml;utf8,<svg xmlns=\\'http://www.w3.org/2000/svg\\' viewBox=\\'0 0 24 24\\' fill=\\'white\\'><path d=\\'M4 5L12 13L20 5V19H16V10L12 14L8 10V19H4V5Z\\'/></svg>';" />
          </div>
          <h2 style="font-size: 21px; font-weight: 900; color: #0f172a; margin: 0; letter-spacing: 0.5px;">MOBIN X</h2>
          <span style="font-size: 11.5px; font-weight: 800; color: #0284c7; letter-spacing: 1.5px; text-transform: uppercase;">GAMING ECOSYSTEM</span>
        </div>

        <!-- 3-Step Indicator: Name -> Phone -> Google -->
        <div style="display: flex; align-items: center; justify-content: center; gap: 8px; margin-bottom: 22px;">
          <div style="display: flex; flex-direction: column; align-items: center; gap: 4px;">
            <div id="stepper-circle-1" style="width: 34px; height: 34px; border-radius: 50%; background: #0066ff; color: #ffffff; display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 13px; box-shadow: 0 2px 8px rgba(0, 102, 255, 0.25);">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
            </div>
            <span style="font-size: 10.5px; font-weight: 700; color: #0066ff;">Name</span>
          </div>
          <div id="line-google-1" style="width: 32px; height: 2px; background: #cbd5e1; margin-bottom: 14px; transition: background 0.3s ease;"></div>
          <div style="display: flex; flex-direction: column; align-items: center; gap: 4px;">
            <div id="stepper-circle-2" style="width: 34px; height: 34px; border-radius: 50%; background: #ffffff; border: 2px solid #cbd5e1; display: flex; align-items: center; justify-content: center; color: #64748b; font-weight: 800; font-size: 13px; transition: all 0.3s ease;">
              <svg width="15" height="15" viewBox="0 0 24 24" fill="currentColor"><path d="M20.01 15.38c-1.23 0-2.42-.2-3.53-.56a.977.977 0 0 0-1.01.24l-1.57 1.97c-2.83-1.35-5.43-3.9-6.63-6.49l1.97-1.57c.26-.26.35-.65.24-1.01A11.36 11.36 0 0 1 8.92 4c0-.55-.45-1-1-1H4.5c-.55 0-1 .45-1 1 0 9.39 7.61 17 17 17 .55 0 1-.45 1-1v-3.62c0-.55-.45-1-1-.02z"/></svg>
            </div>
            <span id="label-google-phone" style="font-size: 10.5px; font-weight: 700; color: #64748b;">Phone</span>
          </div>
          <div id="line-google-2" style="width: 32px; height: 2px; background: #cbd5e1; margin-bottom: 14px; transition: background 0.3s ease;"></div>
          <div style="display: flex; flex-direction: column; align-items: center; gap: 4px;">
            <div id="stepper-circle-3" style="width: 34px; height: 34px; border-radius: 50%; background: #ffffff; border: 2px solid #cbd5e1; display: flex; align-items: center; justify-content: center; font-size: 15px; transition: all 0.3s ease;">
              <svg width="16" height="16" viewBox="0 0 24 24"><path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/><path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/><path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"/><path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"/></svg>
            </div>
            <span style="font-size: 10.5px; font-weight: 700; color: #64748b;">Google</span>
          </div>
        </div>

        <!-- Form Card -->
        <div style="background: #ffffff; border: 1.5px solid #eef2f6; border-radius: 24px; padding: 22px 18px; box-shadow: 0 10px 30px rgba(0, 0, 0, 0.04); display: flex; flex-direction: column; gap: 16px;">
          
          <div>
            <label style="display: block; font-size: 13px; font-weight: 800; color: #0f172a; margin-bottom: 6px;">Full Name</label>
            <div id="wrap-input-name" style="display: flex; align-items: center; border: 1.5px solid #e2e8f0; border-radius: 14px; background: #ffffff; padding: 0 14px; height: 50px; transition: all 0.2s ease;">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
              <input type="text" id="input-onboard-fullname" placeholder="Enter your full name" style="border: none; outline: none; background: transparent; width: 100%; height: 100%; font-size: 14px; color: #0f172a; font-weight: 600; padding-left: 10px;" />
            </div>
          </div>

          <div>
            <label style="display: block; font-size: 13px; font-weight: 800; color: #0f172a; margin-bottom: 6px;">Phone Number (Optional)</label>
            <div id="wrap-input-phone" style="display: flex; align-items: center; border: 1.5px solid #e2e8f0; border-radius: 14px; background: #ffffff; padding: 0 14px; height: 50px; transition: all 0.2s ease;">
              <svg width="17" height="17" viewBox="0 0 24 24" fill="#94a3b8"><path d="M20.01 15.38c-1.23 0-2.42-.2-3.53-.56a.977.977 0 0 0-1.01.24l-1.57 1.97c-2.83-1.35-5.43-3.9-6.63-6.49l1.97-1.57c.26-.26.35-.65.24-1.01A11.36 11.36 0 0 1 8.92 4c0-.55-.45-1-1-1H4.5c-.55 0-1 .45-1 1 0 9.39 7.61 17 17 17 .55 0 1-.45 1-1v-3.62c0-.55-.45-1-1-.02z"/></svg>
              <input type="tel" id="input-onboard-phone-num" placeholder="01XXXXXXXXX" maxlength="14" style="border: none; outline: none; background: transparent; width: 100%; height: 100%; font-size: 14px; color: #0f172a; font-weight: 600; padding-left: 10px;" />
            </div>
          </div>

          <div>
            <button id="btn-continue-google" style="width: 100%; height: 50px; background: #ffffff; border: 1.5px solid #e2e8f0; border-radius: 14px; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 14.5px; font-weight: 800; color: #0f172a; cursor: pointer; transition: all 0.2s ease; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.03);">
              <svg width="20" height="20" viewBox="0 0 24 24">
                <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"/>
                <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"/>
              </svg>
              <span>Continue with Google</span>
            </button>
          </div>

        </div>

      </div>

      <!-- Bottom Complete Button -->
      <div style="position: relative; z-index: 2; margin-top: 20px;">
        <button id="btn-complete-profile" style="width: 100%; height: 52px; background: linear-gradient(135deg, #0066ff 0%, #0052cc 100%); color: #ffffff; border: none; border-radius: 16px; font-size: 15.5px; font-weight: 800; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 10px; box-shadow: 0 8px 24px rgba(0, 102, 255, 0.4); transition: transform 0.15s ease;">
          <span>Complete Your Profile</span>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="5" y1="12" x2="19" y2="12"></line><polyline points="12 5 19 12 12 19"></polyline></svg>
        </button>

        <div style="text-align: center; margin-top: 12px;">
          <span style="font-size: 11px; color: #64748b;">By continuing, you agree to our </span>
          <a href="javascript:void(0)" id="link-onboard-privacy" style="font-size: 11px; font-weight: 700; color: #0066ff; text-decoration: underline;">Privacy Policy & Data Safety</a>
        </div>
      </div>

    </div>
  `;
}

/**
 * Event Handlers
 */
export function bindOnboardingEvents() {
  // Screen 1 Navigation
  document.getElementById('btn-onboard-start')?.addEventListener('click', () => {
    activeAuthMode = 'google-setup';
    stateManager.navigate('onboarding');
  });

  // Google Auth Action
  const handleGoogleAuth = async (nameVal, phoneVal) => {
    const btnGoogle = document.getElementById('btn-continue-google');
    const btnComplete = document.getElementById('btn-complete-profile');
    
    if (btnComplete) {
      btnComplete.disabled = true;
      btnComplete.innerHTML = `<span>Connecting with Google...</span>`;
    }
    if (btnGoogle) {
      btnGoogle.disabled = true;
    }

    try {
      const googleUser = await firebaseService.signInWithGoogle();
      if (!googleUser || !googleUser.email) {
        throw new Error('Google Sign-In was cancelled.');
      }
      const email = googleUser.email;
      const displayName = nameVal || googleUser.displayName || email.split('@')[0];
      const avatar = googleUser.photoURL || 'assets/images/avatar_user.jpg';
      const uid = googleUser.uid;

      const user = await authService.loginWithGoogle(email, displayName, phoneVal || '', '', avatar, uid);
      Toast.show(`🎉 Welcome to Mobin X, ${user.username}!`, 'success');
      stateManager.navigate('home');
    } catch (err) {
      Toast.show(err.message || 'Google Sign-In was cancelled.', 'warning');
      if (btnComplete) {
        btnComplete.disabled = false;
        btnComplete.innerHTML = `<span>Complete Your Profile</span><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="5" y1="12" x2="19" y2="12"></line><polyline points="12 5 19 12 12 19"></polyline></svg>`;
      }
      if (btnGoogle) {
        btnGoogle.disabled = false;
      }
    }
  };

  document.getElementById('btn-continue-google')?.addEventListener('click', () => {
    const nameInput = document.getElementById('input-onboard-fullname');
    const phoneInput = document.getElementById('input-onboard-phone-num');
    handleGoogleAuth(nameInput?.value.trim(), phoneInput?.value.trim());
  });

  document.getElementById('btn-complete-profile')?.addEventListener('click', () => {
    const nameInput = document.getElementById('input-onboard-fullname');
    const phoneInput = document.getElementById('input-onboard-phone-num');
    const fullName = nameInput?.value.trim();
    const phone = phoneInput?.value.trim();

    handleGoogleAuth(fullName, phone);
  });

  // Dynamic 3-step indicator progress in Google Setup
  const syncGoogleStepProgress = () => {
    const nameVal = document.getElementById('input-onboard-fullname')?.value.trim();
    const phoneVal = document.getElementById('input-onboard-phone-num')?.value.trim();
    const s2 = document.getElementById('stepper-circle-2');
    const s3 = document.getElementById('stepper-circle-3');
    const l1 = document.getElementById('line-google-1');
    const l2 = document.getElementById('line-google-2');
    const lblPhone = document.getElementById('label-google-phone');

    if (nameVal && l1 && s2) {
      l1.style.background = '#0066ff';
      s2.style.background = '#0066ff';
      s2.style.borderColor = '#0066ff';
      s2.style.color = '#ffffff';
      if (lblPhone) lblPhone.style.color = '#0066ff';
    }
    if (phoneVal && l2 && s3) {
      l2.style.background = '#0066ff';
    }
  };

  ['input-onboard-fullname', 'input-onboard-phone-num'].forEach(id => {
    document.getElementById(id)?.addEventListener('input', syncGoogleStepProgress);
  });

  // Privacy Policy Link Click
  document.getElementById('link-onboard-privacy')?.addEventListener('click', () => {
    openExternalStore('https://mobinx-admin-console.vercel.app/privacy.html', '#0284c7');
  });
}

/**
 * Reset onboarding helper
 */
export function resetOnboardingStep(mode = 'welcome') {
  activeAuthMode = mode;
}
