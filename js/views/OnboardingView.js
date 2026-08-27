import { authService } from '../services/authService.js';
import { stateManager } from '../services/stateManager.js';
import { firebaseService } from '../services/firebaseService.js';
import { Toast } from '../components/Toast.js';

let onboardStep = 1; // 1 = Welcome Screen (Dark), 2 = Almost There Profile Setup (Matches Image 2)
let selectedGoogleAccount = null;

export function renderOnboardingView() {
  if (onboardStep === 1) {
    return renderWelcomeStep();
  }
  return renderProfileSetupStep();
}

/**
 * Screen 1: Welcome to Mobin X (Dark Futuristic Gaming Aesthetic - Zero White Spaces)
 */
function renderWelcomeStep() {
  return `
    <div class="view-container onboarding-view onboarding-step-1" style="min-height: 100%; height: 100%; box-sizing: border-box; background: radial-gradient(circle at 50% 25%, #061e4f 0%, #030d24 60%, #010614 100%); color: #ffffff; padding: 24px 20px calc(24px + var(--safe-bottom)) 20px; display: flex; flex-direction: column; justify-content: space-between; overflow-y: auto;">
      
      <!-- Top Branding -->
      <div style="display: flex; flex-direction: column; align-items: center; text-align: center; margin-top: 6px;">
        <!-- Logo 'M' Box -->
        <div style="width: 56px; height: 56px; border-radius: 16px; background: linear-gradient(135deg, #0284c7 0%, #2563eb 100%); display: flex; align-items: center; justify-content: center; box-shadow: 0 8px 24px rgba(37, 99, 235, 0.45); margin-bottom: 10px; border: 1.5px solid rgba(56, 189, 248, 0.4);">
          <svg width="32" height="32" viewBox="0 0 24 24" fill="none">
            <path d="M4 5L12 13L20 5V19H16V10L12 14L8 10V19H4V5Z" fill="#ffffff"/>
          </svg>
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
          style="width: 200px; height: 200px; object-fit: cover; border-radius: 26px; border: 1.5px solid rgba(56, 189, 248, 0.3); box-shadow: 0 12px 35px rgba(2, 132, 199, 0.35); position: relative; z-index: 2;"
        />
      </div>

      <!-- 3 Feature Highlight Cards -->
      <div style="display: flex; flex-direction: column; gap: 9px; margin-bottom: 16px;">
        
        <!-- Card 1: Top Up & Diamonds -->
        <div style="background: rgba(15, 23, 42, 0.7); border: 1px solid rgba(56, 189, 248, 0.22); backdrop-filter: blur(10px); border-radius: 14px; padding: 10px 14px; display: flex; align-items: center; gap: 14px;">
          <div style="width: 38px; height: 38px; border-radius: 10px; background: rgba(56, 189, 248, 0.15); border: 1px solid rgba(56, 189, 248, 0.25); display: flex; align-items: center; justify-content: center; font-size: 19px; flex-shrink: 0;">
            💎
          </div>
          <div>
            <div style="font-size: 13.5px; font-weight: 800; color: #ffffff; letter-spacing: 0.2px;">Top Up & Diamonds</div>
            <div style="font-size: 11.5px; color: #94a3b8; font-weight: 500;">Fast & secure top up</div>
          </div>
        </div>

        <!-- Card 2: Tournaments -->
        <div style="background: rgba(15, 23, 42, 0.7); border: 1px solid rgba(245, 158, 11, 0.22); backdrop-filter: blur(10px); border-radius: 14px; padding: 10px 14px; display: flex; align-items: center; gap: 14px;">
          <div style="width: 38px; height: 38px; border-radius: 10px; background: rgba(245, 158, 11, 0.15); border: 1px solid rgba(245, 158, 11, 0.25); display: flex; align-items: center; justify-content: center; font-size: 19px; flex-shrink: 0;">
            🏆
          </div>
          <div>
            <div style="font-size: 13.5px; font-weight: 800; color: #ffffff; letter-spacing: 0.2px;">Tournaments</div>
            <div style="font-size: 11.5px; color: #94a3b8; font-weight: 500;">Join exciting battles</div>
          </div>
        </div>

        <!-- Card 3: Rewards & More -->
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
      <div>
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
 * Screen 2: Almost There! (Exact Replica of User's Image 2 with 3-Step Stepper & Native Google Auth)
 */
function renderProfileSetupStep() {
  return `
    <div class="view-container onboarding-view onboarding-step-2" style="min-height: 100%; height: 100%; box-sizing: border-box; background: linear-gradient(180deg, #f0f7ff 0%, #f8fafc 40%, #eef5ff 100%); color: #0f172a; padding: 20px 20px calc(24px + var(--safe-bottom)) 20px; display: flex; flex-direction: column; justify-content: space-between; overflow-y: auto; position: relative;">
      
      <!-- Top Decorative Aura -->
      <div style="position: absolute; top: -60px; left: -60px; width: 220px; height: 220px; background: radial-gradient(circle, rgba(186, 230, 253, 0.6) 0%, rgba(240, 247, 255, 0) 70%); border-radius: 50%; pointer-events: none; z-index: 1;"></div>
      <div style="position: absolute; bottom: 0; right: -40px; width: 200px; height: 200px; background: radial-gradient(circle, rgba(219, 234, 254, 0.6) 0%, rgba(240, 247, 255, 0) 70%); border-radius: 50%; pointer-events: none; z-index: 1;"></div>

      <div style="position: relative; z-index: 2;">
        
        <!-- Top Branding (Matching Image 2) -->
        <div style="display: flex; flex-direction: column; align-items: center; text-align: center; margin-top: 6px; margin-bottom: 22px;">
          <!-- Logo 'M' Box -->
          <div style="width: 58px; height: 58px; border-radius: 16px; background: linear-gradient(135deg, #0284c7 0%, #2563eb 100%); display: flex; align-items: center; justify-content: center; box-shadow: 0 10px 25px rgba(37, 99, 235, 0.35); margin-bottom: 12px;">
            <svg width="34" height="34" viewBox="0 0 24 24" fill="none">
              <path d="M4 5L12 13L20 5V19H16V10L12 14L8 10V19H4V5Z" fill="#ffffff"/>
            </svg>
          </div>

          <h2 style="font-size: 22px; font-weight: 900; color: #0f172a; margin: 0; font-family: var(--font-heading); letter-spacing: 0.5px;">
            MOBIN X
          </h2>
          <span style="font-size: 10px; font-weight: 800; color: #0284c7; letter-spacing: 1.8px; margin-top: 3px;">
            GAMING ECOSYSTEM
          </span>
        </div>

        <!-- 3-Step Stepper Component (Exact match to Image 2) -->
        <div style="display: flex; align-items: center; justify-content: center; max-width: 320px; margin: 0 auto 24px auto; width: 100%;">
          
          <!-- Step 1: Name -->
          <div style="display: flex; flex-direction: column; align-items: center; gap: 6px;" id="stepper-item-1">
            <div id="stepper-circle-1" style="width: 44px; height: 44px; border-radius: 50%; background: #ffffff; border: 2px solid #3b82f6; color: #2563eb; display: flex; align-items: center; justify-content: center; box-shadow: 0 4px 12px rgba(37, 99, 235, 0.15); transition: all 0.3s ease;">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                <circle cx="12" cy="7" r="4"></circle>
              </svg>
            </div>
            <span id="stepper-label-1" style="font-size: 11.5px; font-weight: 700; color: #0f172a;">Name</span>
          </div>

          <!-- Connector 1 -->
          <div id="stepper-line-1" style="flex: 1; height: 3px; background: #e2e8f0; margin: -18px 8px 0 8px; border-radius: 2px; transition: background 0.3s ease;"></div>

          <!-- Step 2: Phone -->
          <div style="display: flex; flex-direction: column; align-items: center; gap: 6px;" id="stepper-item-2">
            <div id="stepper-circle-2" style="width: 44px; height: 44px; border-radius: 50%; background: #ffffff; border: 2px solid #cbd5e1; color: #64748b; display: flex; align-items: center; justify-content: center; transition: all 0.3s ease;">
              <svg width="19" height="19" viewBox="0 0 24 24" fill="currentColor">
                <path d="M20.01 15.38c-1.23 0-2.42-.2-3.53-.56a.977.977 0 0 0-1.01.24l-1.57 1.97c-2.83-1.35-5.43-3.9-6.63-6.49l1.97-1.57c.26-.26.35-.65.24-1.01A11.36 11.36 0 0 1 8.92 4c0-.55-.45-1-1-1H4.5c-.55 0-1 .45-1 1 0 9.39 7.61 17 17 17 .55 0 1-.45 1-1v-3.62c0-.55-.45-1-1-.02z"/>
              </svg>
            </div>
            <span id="stepper-label-2" style="font-size: 11.5px; font-weight: 700; color: #64748b;">Phone</span>
          </div>

          <!-- Connector 2 (Dashed/Solid) -->
          <div id="stepper-line-2" style="flex: 1; height: 3px; background: #e2e8f0; margin: -18px 8px 0 8px; border-radius: 2px; transition: background 0.3s ease;"></div>

          <!-- Step 3: Google -->
          <div style="display: flex; flex-direction: column; align-items: center; gap: 6px;" id="stepper-item-3">
            <div id="stepper-circle-3" style="width: 44px; height: 44px; border-radius: 50%; background: #ffffff; border: 2px solid #cbd5e1; color: #64748b; display: flex; align-items: center; justify-content: center; transition: all 0.3s ease;">
              <svg width="20" height="20" viewBox="0 0 24 24">
                <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"/>
                <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"/>
              </svg>
            </div>
            <span id="stepper-label-3" style="font-size: 11.5px; font-weight: 700; color: #64748b;">Google</span>
          </div>

        </div>

        <!-- Main Form Card (Matching Image 2) -->
        <div style="background: #ffffff; border: 1.5px solid #eef2f6; border-radius: 24px; padding: 22px 18px; box-shadow: 0 10px 30px rgba(0, 0, 0, 0.04); display: flex; flex-direction: column; gap: 16px;">
          
          <!-- Field 1: Full Name -->
          <div>
            <label style="display: block; font-size: 13.5px; font-weight: 800; color: #0f172a; margin-bottom: 8px;">
              Full Name
            </label>
            <div id="wrap-input-name" style="display: flex; align-items: center; border: 1.5px solid #e2e8f0; border-radius: 14px; background: #ffffff; padding: 0 14px; height: 50px; transition: all 0.2s ease;">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" stroke-width="2" style="flex-shrink: 0;">
                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                <circle cx="12" cy="7" r="4"></circle>
              </svg>
              <input 
                type="text" 
                id="input-onboard-fullname" 
                placeholder="Enter your full name" 
                style="border: none; outline: none; background: transparent; width: 100%; height: 100%; font-size: 13.5px; color: #0f172a; font-weight: 600; padding-left: 10px;"
              />
            </div>
          </div>

          <!-- Field 2: Phone Number -->
          <div>
            <label style="display: block; font-size: 13.5px; font-weight: 800; color: #0f172a; margin-bottom: 8px;">
              Phone Number
            </label>
            <div id="wrap-input-phone" style="display: flex; align-items: center; border: 1.5px solid #e2e8f0; border-radius: 14px; background: #ffffff; padding: 0 14px; height: 50px; transition: all 0.2s ease;">
              <svg width="17" height="17" viewBox="0 0 24 24" fill="#94a3b8" style="flex-shrink: 0;">
                <path d="M20.01 15.38c-1.23 0-2.42-.2-3.53-.56a.977.977 0 0 0-1.01.24l-1.57 1.97c-2.83-1.35-5.43-3.9-6.63-6.49l1.97-1.57c.26-.26.35-.65.24-1.01A11.36 11.36 0 0 1 8.92 4c0-.55-.45-1-1-1H4.5c-.55 0-1 .45-1 1 0 9.39 7.61 17 17 17 .55 0 1-.45 1-1v-3.62c0-.55-.45-1-1-.02z"/>
              </svg>
              <input 
                type="tel" 
                id="input-onboard-phone-num" 
                placeholder="01XXXXXXXXX" 
                maxlength="14"
                style="border: none; outline: none; background: transparent; width: 100%; height: 100%; font-size: 13.5px; color: #0f172a; font-weight: 600; padding-left: 10px;"
              />
            </div>
          </div>

          <!-- Field 3: Continue with Google Button (Matching Image 2) -->
          <div>
            <button id="btn-continue-google" style="width: 100%; height: 50px; background: #ffffff; border: 1.5px solid #e2e8f0; border-radius: 14px; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 14.5px; font-weight: 800; color: #0f172a; cursor: pointer; transition: all 0.2s ease;">
              <svg width="20" height="20" viewBox="0 0 24 24">
                <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"/>
                <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"/>
              </svg>
              <span id="btn-google-text">Continue with Google</span>
            </button>
          </div>

        </div>

        <!-- Trust Card (Matching Image 2) -->
        <div style="background: rgba(239, 246, 255, 0.85); border: 1px solid rgba(191, 219, 254, 0.8); border-radius: 16px; padding: 13px 15px; display: flex; align-items: center; gap: 12px; margin-top: 18px;">
          <div style="width: 36px; height: 36px; border-radius: 10px; background: #2563eb; display: flex; align-items: center; justify-content: center; color: #ffffff; flex-shrink: 0; box-shadow: 0 4px 10px rgba(37, 99, 235, 0.25);">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
              <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
              <path d="M9 12l2 2 4-4"/>
            </svg>
          </div>
          <div>
            <div style="font-size: 12.5px; font-weight: 800; color: #1e293b;">Your information is safe with us.</div>
            <div style="font-size: 11px; color: #64748b; margin-top: 1px;">We'll never share your data without permission.</div>
          </div>
        </div>

      </div>

      <!-- Bottom Complete Your Profile Button (Matching Image 2) -->
      <div style="position: relative; z-index: 2; margin-top: 24px;">
        <button id="btn-complete-profile" style="width: 100%; height: 54px; background: linear-gradient(135deg, #0066ff 0%, #0052cc 100%); color: #ffffff; border: none; border-radius: 16px; font-size: 15.5px; font-weight: 800; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 10px; box-shadow: 0 8px 24px rgba(0, 102, 255, 0.4); transition: transform 0.15s ease;">
          <span>Complete Your Profile</span>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
            <line x1="5" y1="12" x2="19" y2="12"></line>
            <polyline points="12 5 19 12 12 19"></polyline>
          </svg>
        </button>
      </div>

    </div>
  `;
}

export function bindOnboardingEvents() {
  // Step 1: Let's Get Started -> Go to Step 2
  document.getElementById('btn-onboard-start')?.addEventListener('click', () => {
    onboardStep = 2;
    stateManager.navigate('onboarding');
  });

  // Step 2 Form Elements
  const nameInput = document.getElementById('input-onboard-fullname');
  const phoneInput = document.getElementById('input-onboard-phone-num');
  const wrapName = document.getElementById('wrap-input-name');
  const wrapPhone = document.getElementById('wrap-input-phone');
  const btnGoogle = document.getElementById('btn-continue-google');
  const btnGoogleText = document.getElementById('btn-google-text');
  const btnComplete = document.getElementById('btn-complete-profile');

  // Stepper Elements
  const stepCircle1 = document.getElementById('stepper-circle-1');
  const stepLabel1 = document.getElementById('stepper-label-1');
  const stepLine1 = document.getElementById('stepper-line-1');
  const stepCircle2 = document.getElementById('stepper-circle-2');
  const stepLabel2 = document.getElementById('stepper-label-2');
  const stepLine2 = document.getElementById('stepper-line-2');
  const stepCircle3 = document.getElementById('stepper-circle-3');
  const stepLabel3 = document.getElementById('stepper-label-3');

  function updateStepper() {
    const hasName = (nameInput?.value?.trim().length >= 2);
    const hasPhone = (phoneInput?.value?.replace(/[^0-9]/g, '').length >= 11);
    const hasGoogle = !!selectedGoogleAccount;

    // Step 1: Name
    if (stepCircle1 && stepLine1) {
      if (hasName) {
        stepCircle1.style.borderColor = '#2563eb';
        stepCircle1.style.background = '#eff6ff';
        stepCircle1.style.color = '#2563eb';
        if (stepLabel1) stepLabel1.style.color = '#2563eb';
        stepLine1.style.background = '#2563eb';
      } else {
        stepCircle1.style.borderColor = '#cbd5e1';
        stepCircle1.style.background = '#ffffff';
        stepCircle1.style.color = '#64748b';
        if (stepLabel1) stepLabel1.style.color = '#64748b';
        stepLine1.style.background = '#e2e8f0';
      }
    }

    // Step 2: Phone
    if (stepCircle2 && stepLine2) {
      if (hasPhone) {
        stepCircle2.style.borderColor = '#2563eb';
        stepCircle2.style.background = '#eff6ff';
        stepCircle2.style.color = '#2563eb';
        if (stepLabel2) stepLabel2.style.color = '#2563eb';
        stepLine2.style.background = '#2563eb';
      } else {
        stepCircle2.style.borderColor = hasName ? '#3b82f6' : '#cbd5e1';
        stepCircle2.style.background = '#ffffff';
        stepCircle2.style.color = hasName ? '#2563eb' : '#64748b';
        if (stepLabel2) stepLabel2.style.color = hasName ? '#0f172a' : '#64748b';
        stepLine2.style.background = '#e2e8f0';
      }
    }

    // Step 3: Google
    if (stepCircle3) {
      if (hasGoogle) {
        stepCircle3.style.borderColor = '#10b981';
        stepCircle3.style.background = '#ecfdf5';
        if (stepLabel3) {
          stepLabel3.style.color = '#10b981';
          stepLabel3.textContent = 'Verified ✓';
        }
      } else {
        stepCircle3.style.borderColor = (hasName && hasPhone) ? '#3b82f6' : '#cbd5e1';
        stepCircle3.style.background = '#ffffff';
        if (stepLabel3) {
          stepLabel3.style.color = (hasName && hasPhone) ? '#0f172a' : '#64748b';
          stepLabel3.textContent = 'Google';
        }
      }
    }
  }

  nameInput?.addEventListener('input', () => {
    if (wrapName) wrapName.style.borderColor = '#3b82f6';
    updateStepper();
  });

  nameInput?.addEventListener('blur', () => {
    if (wrapName && !nameInput.value.trim()) wrapName.style.borderColor = '#e2e8f0';
  });

  phoneInput?.addEventListener('input', () => {
    if (wrapPhone) wrapPhone.style.borderColor = '#3b82f6';
    updateStepper();
  });

  phoneInput?.addEventListener('blur', () => {
    if (wrapPhone && !phoneInput.value.trim()) wrapPhone.style.borderColor = '#e2e8f0';
  });

  // Continue with Google Button Click
  btnGoogle?.addEventListener('click', async () => {
    if (btnGoogleText) btnGoogleText.textContent = 'Connecting to Google...';
    btnGoogle.style.borderColor = '#3b82f6';

    try {
      // Launch Google Sign-In (Native Account Picker or Web Popup)
      const googleUser = await firebaseService.signInWithGoogle();

      if (!googleUser || !googleUser.email) {
        throw new Error('Google Sign-In was cancelled');
      }

      selectedGoogleAccount = googleUser;

      // Update button to show verified state
      if (btnGoogleText) {
        btnGoogleText.innerHTML = `✓ <span style="color: #059669; font-weight: 800;">${googleUser.email}</span>`;
      }
      btnGoogle.style.borderColor = '#10b981';
      btnGoogle.style.background = '#f0fdf4';

      // If name was not entered yet, auto-fill from Google account
      if (nameInput && !nameInput.value.trim() && googleUser.displayName) {
        nameInput.value = googleUser.displayName;
      }

      updateStepper();
      Toast.show(`✓ Google Account Selected: ${googleUser.email}`, 'success');

      // Auto-focus on Phone if still empty
      if (phoneInput && !phoneInput.value.trim()) {
        phoneInput.focus();
      }
    } catch (err) {
      console.warn('Google Sign-In Notice:', err);
      if (btnGoogleText) btnGoogleText.textContent = 'Continue with Google';
      btnGoogle.style.borderColor = '#ef4444';
      Toast.show(err.message || 'Google account selection was cancelled', 'warning');
    }
  });

  // Complete Your Profile Button Click (Strict Validation)
  btnComplete?.addEventListener('click', async () => {
    let hasError = false;
    const fullName = nameInput?.value?.trim() || '';
    const phone = phoneInput?.value?.trim() || '';
    const cleanDigits = phone.replace(/[^0-9]/g, '');

    // Reset error borders
    if (wrapName) wrapName.style.borderColor = '#e2e8f0';
    if (wrapPhone) wrapPhone.style.borderColor = '#e2e8f0';
    if (btnGoogle) btnGoogle.style.borderColor = selectedGoogleAccount ? '#10b981' : '#e2e8f0';

    // 1. Validate Full Name
    if (!fullName || fullName.length < 2) {
      if (wrapName) {
        wrapName.style.borderColor = '#ef4444';
        wrapName.style.boxShadow = '0 0 0 3px rgba(239, 68, 68, 0.15)';
      }
      Toast.show('Please enter your Full Name', 'warning');
      nameInput?.focus();
      hasError = true;
      return;
    }

    // 2. Validate Phone Number
    if (!phone || cleanDigits.length < 11) {
      if (wrapPhone) {
        wrapPhone.style.borderColor = '#ef4444';
        wrapPhone.style.boxShadow = '0 0 0 3px rgba(239, 68, 68, 0.15)';
      }
      Toast.show('Please enter a valid 11-digit phone number (e.g. 017XXXXXXXX)', 'warning');
      phoneInput?.focus();
      hasError = true;
      return;
    }

    // 3. Validate Google Account Selection
    if (!selectedGoogleAccount) {
      if (btnGoogle) {
        btnGoogle.style.borderColor = '#ef4444';
        btnGoogle.style.boxShadow = '0 0 0 3px rgba(239, 68, 68, 0.15)';
      }
      Toast.show('Please click "Continue with Google" to select your Gmail', 'warning');
      hasError = true;
      return;
    }

    // All 3 steps complete! Save Profile and Enter App
    btnComplete.style.transform = 'scale(0.98)';
    btnComplete.innerHTML = `<span>Saving Profile...</span>`;

    try {
      const email = selectedGoogleAccount.email;
      const avatarUrl = selectedGoogleAccount.photoURL || '';
      const user = await authService.loginWithGoogle(email, fullName, cleanDigits, '', avatarUrl);
      authService.setOnboardingCompleted(true);
      Toast.show(`🎉 Welcome to Mobin X, ${user.username || fullName}!`, 'success');
      stateManager.navigate('home');
    } catch (e) {
      console.error('Save Profile Error:', e);
      authService.setOnboardingCompleted(true);
      Toast.show(`🎉 Welcome to Mobin X!`, 'success');
      stateManager.navigate('home');
    }
  });
}

/**
 * Helper to reset onboarding to step 1 if accessed from drawer
 */
export function resetOnboardingStep(step = 1) {
  onboardStep = step;
  selectedGoogleAccount = null;
}
