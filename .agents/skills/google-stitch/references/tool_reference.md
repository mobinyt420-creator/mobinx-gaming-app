# StitchMCP Detailed Tool Reference

This document details parameters, schemas, and return formats for StitchMCP tools.

---

## 1. `create_project`
- **Description**: Creates a new Stitch project container.
- **Parameters**:
  - `title` (*string, optional*): Title of the project.
- **Example Response**:
  ```json
  {
    "name": "projects/4044680601076201931",
    "title": "My Web Application"
  }
  ```

---

## 2. `generate_screen_from_text`
- **Description**: Generates a UI screen from natural language description.
- **Parameters**:
  - `projectId` (*string, required*): The ID of the project (e.g. `4044680601076201931`).
  - `prompt` (*string, required*): Text prompt describing the target UI.
  - `deviceType` (*string, optional*): `DESKTOP` | `MOBILE` | `TABLET` | `AGNOSTIC`.
  - `modelId` (*string, optional*): `GEMINI_3_1_PRO` (recommended) | `GEMINI_3_FLASH`.
  - `designSystem` (*string, optional*): The design system resource name (e.g. `assets/15996705518239280238`).

---

## 3. `get_screen`
- **Description**: Fetches HTML, CSS, assets, and details of a screen.
- **Parameters**:
  - `name` (*string, required*): Resource name (e.g. `projects/4044680601076201931/screens/98b50e2ddc9943efb387052637738f61`).
  - `projectId` (*string, required*): Project ID.
  - `screenId` (*string, required*): Screen ID.

---

## 4. `edit_screens`
- **Description**: Edits one or more existing screens.
- **Parameters**:
  - `projectId` (*string, required*): Project ID.
  - `selectedScreenIds` (*string[], required*): List of screen IDs to modify.
  - `prompt` (*string, required*): Instructions on modifications to make.
  - `deviceType` (*string, optional*): `DESKTOP` | `MOBILE` | `TABLET`.
  - `modelId` (*string, optional*): `GEMINI_3_1_PRO` | `GEMINI_3_FLASH`.

---

## 5. `generate_variants`
- **Description**: Generates stylistic or structural variants of existing screens.
- **Parameters**:
  - `projectId` (*string, required*): Project ID.
  - `selectedScreenIds` (*string[], required*): Screen IDs to vary.
  - `prompt` (*string, required*): Variant prompt.
  - `variantOptions` (*object, required*):
    - `variantCount` (*int*): 1 to 5.
    - `creativeRange` (*string*): `REFINE` | `EXPLORE` | `REIMAGINE`.
    - `aspects` (*string[]*): Any of `["LAYOUT", "COLOR_SCHEME", "IMAGES", "TEXT_FONT", "TEXT_CONTENT"]`.

---

## 6. `upload_design_md` & `create_design_system_from_design_md`
- **Parameters (`upload_design_md`)**:
  - `projectId` (*string, required*): Project ID.
  - `designMdBase64` (*string, required*): Base64 encoded UTF-8 string of `DESIGN.md`.
- **Parameters (`create_design_system_from_design_md`)**:
  - `projectId` (*string, required*): Project ID.
  - `selectedScreenInstance` (*object, required*):
    - `id`: Screen instance ID from `get_project`.
    - `sourceScreen`: `projects/<projectId>/screens/<screenId>`.
