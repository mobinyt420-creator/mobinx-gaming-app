class SensitivityService {
  calculate(config) {
    const { brand = "Samsung", ram = "6GB", dpi = "420", style = "Drag Headshot" } = config;

    let general = 198;
    let redDot = 192;
    let scope2x = 182;
    let scope4x = 170;
    let sniper = 125;
    let freeLook = 155;
    let fireButtonSize = "44%";
    let recommendedDpi = dpi || "460";

    const ramNum = parseInt(ram) || 6;
    const isIPhone = brand.toLowerCase().includes('iphone') || brand.toLowerCase().includes('apple');

    if (isIPhone) {
      // iPhone ProMotion has 120Hz native touch sampling
      general = 192;
      redDot = 188;
      scope2x = 178;
      scope4x = 168;
      sniper = 115;
      freeLook = 145;
      fireButtonSize = "42%";
      recommendedDpi = "Standard iOS";
    } else if (ramNum <= 4) {
      // Low RAM Android: needs max drag sensitivity to bypass input lag
      general = 200;
      redDot = 198;
      scope2x = 188;
      scope4x = 176;
      sniper = 135;
      freeLook = 165;
      fireButtonSize = "48%";
      recommendedDpi = "480 - 520";
    } else if (ramNum >= 8) {
      // High-End Android (90Hz / 120Hz Display)
      general = 196;
      redDot = 192;
      scope2x = 184;
      scope4x = 172;
      sniper = 120;
      freeLook = 150;
      fireButtonSize = "44%";
      recommendedDpi = "440 - 460";
    }

    // Playstyle-specific calibration based on esports competitive meta
    switch (style) {
      case "One Tap (White444 Style)":
      case "One Tap":
        general = 200;
        redDot = 198;
        scope2x = 180;
        scope4x = 165;
        sniper = 110;
        freeLook = 140;
        fireButtonSize = "42%";
        break;

      case "Drag Headshot (Ruok FF Style)":
      case "Drag Headshot":
        general = 200;
        redDot = 195;
        scope2x = 186;
        scope4x = 175;
        sniper = 125;
        freeLook = 160;
        fireButtonSize = "44%";
        break;

      case "Rush & Fast Gloo Wall (Raistar Style)":
      case "Rush":
        general = 199;
        redDot = 194;
        scope2x = 185;
        scope4x = 172;
        sniper = 138;
        freeLook = 180;
        fireButtonSize = "46%";
        break;

      case "Balanced Competitive (Tournament Meta)":
      case "Balanced":
        general = 190;
        redDot = 184;
        scope2x = 174;
        scope4x = 164;
        sniper = 118;
        freeLook = 148;
        fireButtonSize = "45%";
        break;

      default:
        break;
    }

    return {
      game: "Free Fire (OB45+ Meta)",
      brand,
      ram,
      dpi: recommendedDpi,
      style,
      values: {
        general,
        redDot,
        scope2x,
        scope4x,
        sniper,
        freeLook
      },
      proTips: [
        `Recommended Fire Button Size: ${fireButtonSize} placed at lower-right zone.`,
        `Display Setting: Graphics = Smooth, High FPS = High (Minimizes frame jitter & touch latency).`,
        `Drag Technique: Straight 'J-Drag' for M1887/Desert Eagle and 'Linear Drag' for AR guns.`
      ]
    };
  }
}

export const sensitivityService = new SensitivityService();
