---
name: google-stitch
description: >-
  Guide and workflows for using Google Stitch (StitchMCP) to create UI projects, generate screens from text prompts, iterate on UI designs, generate design variants, and create or apply design systems.
---

# Google Stitch Skill

Google Stitch is a UI/UX design and frontend code generation platform integrated with Antigravity via **StitchMCP**. Use this skill to manage Stitch projects, generate responsive UI screens, iterate on designs, create variants, and enforce design systems.

---

## Stitch MCP Overview

All Stitch tools are lazily-loaded under the MCP server `StitchMCP`. When invoking tools, use `call_mcp_tool` with `ServerName: "StitchMCP"` and the corresponding `ToolName`.

### Available Tools

| Tool Name | Purpose | Key Parameters |
| :--- | :--- | :--- |
| `create_project` | Create a new container for UI designs and screens | `title` (string) |
| `list_projects` | List all available Stitch projects | `pageSize`, `pageToken` |
| `get_project` | Fetch metadata, screens, and design systems for a project | `name` (`projects/{projectId}`) |
| `delete_project` | Delete a project | `name` (`projects/{projectId}`) |
| `generate_screen_from_text` | Generate a new UI screen from a natural language prompt | `projectId`, `prompt`, `deviceType`, `modelId`, `designSystem` |
| `list_screens` | List screens in a project | `projectId`, `pageSize`, `pageToken` |
| `get_screen` | Retrieve details, HTML/CSS code, and metadata of a screen | `name` (`projects/{projectId}/screens/{screenId}`) |
| `edit_screens` | Modify existing screen(s) based on text instructions | `projectId`, `selectedScreenIds`, `prompt`, `deviceType`, `modelId` |
| `generate_variants` | Create multiple variations of an existing screen | `projectId`, `selectedScreenIds`, `prompt`, `variantOptions` |
| `upload_design_md` | Upload `DESIGN.md` (Base64) to establish design tokens | `projectId`, `designMdBase64` |
| `create_design_system_from_design_md` | Build a design system from an uploaded `DESIGN.md` | `projectId`, `selectedScreenInstance`, `deviceType` |
| `create_design_system` / `update_design_system` | Manage full design system tokens and themes | `projectId`, `designSystem` |
| `list_design_systems` | List design systems in a project | `projectId` |
| `apply_design_system` | Apply an existing design system to screens | `projectId`, `designSystemId`, `screenIds` |

---

## Core Workflows

### 1. Creating a Project & Generating a Screen

1. **Create or select a project**:
   ```json
   {
     "ServerName": "StitchMCP",
     "ToolName": "create_project",
     "Arguments": {
       "title": "E-Commerce Dashboard"
     }
   }
   ```
   Note the returned `projectId`.

2. **Generate screen from prompt**:
   ```json
   {
     "ServerName": "StitchMCP",
     "ToolName": "generate_screen_from_text",
     "Arguments": {
       "projectId": "<PROJECT_ID>",
       "prompt": "Modern SaaS analytics dashboard with dark theme, sidebar navigation, revenue chart, and recent transaction table",
       "deviceType": "DESKTOP",
       "modelId": "GEMINI_3_1_PRO"
     }
   }
   ```

3. **Handle output**:
   - If `output_components` contains suggestions (e.g. "Yes, make them all"), present them to the user.
   - If the user accepts a suggestion, call `generate_screen_from_text` again with the accepted suggestion prompt.

---

### 2. Iterating & Editing Screens

To edit an existing screen:
```json
{
  "ServerName": "StitchMCP",
  "ToolName": "edit_screens",
  "Arguments": {
    "projectId": "<PROJECT_ID>",
    "selectedScreenIds": ["<SCREEN_ID>"],
    "prompt": "Add a date range filter to the header and change primary CTA button color to indigo",
    "deviceType": "DESKTOP",
    "modelId": "GEMINI_3_1_PRO"
  }
}
```

---

### 3. Generating Design Variants

To explore different design directions for an existing screen:
```json
{
  "ServerName": "StitchMCP",
  "ToolName": "generate_variants",
  "Arguments": {
    "projectId": "<PROJECT_ID>",
    "selectedScreenIds": ["<SCREEN_ID>"],
    "prompt": "Explore alternative minimalist layouts with high-contrast typography",
    "variantOptions": {
      "variantCount": 3,
      "creativeRange": "EXPLORE",
      "aspects": ["LAYOUT", "COLOR_SCHEME", "TEXT_FONT"]
    }
  }
}
```

**Creative Range Options**:
- `REFINE`: Subtle refinements closely adhering to original.
- `EXPLORE`: Balanced exploration (default).
- `REIMAGINE`: Radical redesigns fundamentally challenging the original.

**Aspects**: `LAYOUT`, `COLOR_SCHEME`, `IMAGES`, `TEXT_FONT`, `TEXT_CONTENT`.

---

### 4. Creating Design Systems from `DESIGN.md`

1. **Encode `DESIGN.md` to base64** (UTF-8).
2. **Upload `DESIGN.md`**:
   ```json
   {
     "ServerName": "StitchMCP",
     "ToolName": "upload_design_md",
     "Arguments": {
       "projectId": "<PROJECT_ID>",
       "designMdBase64": "<BASE64_STRING>"
     }
   }
   ```
3. **Build the design system**:
   ```json
   {
     "ServerName": "StitchMCP",
     "ToolName": "create_design_system_from_design_md",
     "Arguments": {
       "projectId": "<PROJECT_ID>",
       "selectedScreenInstance": {
         "id": "<SCREEN_INSTANCE_ID>",
         "sourceScreen": "projects/<PROJECT_ID>/screens/<SCREEN_ID>"
       },
       "deviceType": "DESKTOP"
     }
   }
   ```

---

## Best Practices & Guidelines

1. **Recommended Models**:
   - Use `GEMINI_3_1_PRO` for complex layouts, rich UI components, and high-fidelity generation.
   - Use `GEMINI_3_FLASH` for fast iterations.
   - *Note*: `GEMINI_3_PRO` is deprecated.
2. **Device Types**:
   - Explicitly specify `DESKTOP`, `MOBILE`, or `TABLET` depending on user requirements.
3. **Timeout & Polling Handling**:
   - Screen generation can take several minutes. DO NOT retry immediately on timeout.
   - If a timeout occurs, call `get_screen` every 30 seconds (up to 10 times) to retrieve the completed result.
4. **Design Consistency**:
   - Always associate screens with a `designSystem` ID when available to maintain cohesive typography, color tokens, and spacing across the project.
