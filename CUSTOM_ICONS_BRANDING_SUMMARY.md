# Custom Icons Branding Assets Summary

## Overview

This document summarizes the enhanced custom icons functionality added to the `branding_assets.sh` script. The new feature allows conditional processing of bottom menu items with custom SVG icons based on the `IS_BOTTOMMENU` environment variable.

## New Features

### 1. Conditional Bottom Menu Processing

- **Environment Variable**: `IS_BOTTOMMENU`
- **Values**: `true` (process) or `false` (skip)
- **Default**: `false` (skips processing)

### 2. JSON Format Support for Custom Icons

- **New Format**: JSON array with `type`, `label`, and `icon_url` fields
- **Custom Type**: `"type": "custom"` triggers icon download
- **Default Type**: `"type": "default"` skips icon download

### 3. SVG Icon Download

- **Target Directory**: `assets/icons/`
- **File Naming**: `{label}.svg`
- **Download Source**: `icon_url` field from JSON

## Implementation Details

### Environment Variables

#### Required Variables

- `IS_BOTTOMMENU`: Controls whether bottom menu processing is enabled
  - `true`: Process bottom menu items and download custom icons
  - `false`: Skip bottom menu processing entirely

#### Optional Variables

- `BOTTOMMENU_ITEMS`: JSON array or legacy format string
  - **JSON Format**: `[{"type":"custom","label":"Home","icon_url":"https://..."}]`
  - **Legacy Format**: `"icon1:label1,icon2:label2"`

### JSON Format Specification

#### Custom Icon Item

```json
{
  "type": "custom",
  "label": "Home",
  "icon_url": "https://example.com/home.svg"
}
```

#### Default Item (No Icon)

```json
{
  "type": "default",
  "label": "Settings"
}
```

#### Complete Example

```json
[
  {
    "type": "custom",
    "label": "Home",
    "icon_url": "https://example.com/home.svg"
  },
  { "type": "default", "label": "Notifications" },
  {
    "type": "custom",
    "label": "Profile",
    "icon_url": "https://example.com/profile.svg"
  }
]
```

### Processing Logic

#### Step 1: Check IS_BOTTOMMENU

```bash
if [ "${IS_BOTTOMMENU:-false}" != "true" ]; then
    log_info "IS_BOTTOMMENU is not set to 'true', skipping bottom menu configuration"
    return 0
fi
```

#### Step 2: Detect Format

- **JSON Detection**: Checks if `BOTTOMMENU_ITEMS` starts with `[` and ends with `]`
- **Legacy Fallback**: Uses comma-separated format if not JSON

#### Step 3: Process Custom Icons

```bash
if [ "$item_type" = "custom" ] && [ -n "$item_icon_url" ]; then
    # Download SVG icon from icon_url
    local icon_filename="${item_label}.svg"
    local icon_path="assets/icons/$icon_filename"
    download_asset_with_fallbacks "$item_icon_url" "$icon_path" "custom icon $item_label"
fi
```

#### Step 4: Generate Configuration

- Creates `assets/icons/menu_config.json` with processed items
- Includes icon filenames, labels, and types

## Usage Examples

### Example 1: Enable Custom Icons

```bash
export IS_BOTTOMMENU="true"
export BOTTOMMENU_ITEMS='[{"type":"custom","label":"Home","icon_url":"https://example.com/home.svg"},{"type":"default","label":"Settings"}]'
bash lib/scripts/ios/branding_assets.sh
```

### Example 2: Disable Bottom Menu

```bash
export IS_BOTTOMMENU="false"
# BOTTOMMENU_ITEMS will be ignored
bash lib/scripts/ios/branding_assets.sh
```

### Example 3: Legacy Format

```bash
export IS_BOTTOMMENU="true"
export BOTTOMMENU_ITEMS="https://example.com/home.png:Home,https://example.com/profile.png:Profile"
bash lib/scripts/ios/branding_assets.sh
```

## File Structure

### Generated Files

```
assets/
├── icons/
│   ├── Home.svg              # Custom icon for "Home" label
│   ├── Profile.svg           # Custom icon for "Profile" label
│   └── menu_config.json      # Menu configuration file
```

### Menu Configuration File

```json
[
  { "icon": "Home.svg", "label": "Home", "type": "custom" },
  { "label": "Settings", "type": "default" },
  { "icon": "Profile.svg", "label": "Profile", "type": "custom" }
]
```

## Error Handling

### Download Failures

- **Fallback**: Creates minimal PNG placeholder
- **Logging**: Warns about download failures
- **Continuation**: Continues processing other items

### JSON Parsing

- **Primary**: Uses `jq` if available
- **Fallback**: Basic string manipulation
- **Validation**: Checks for required fields

### Missing Variables

- **IS_BOTTOMMENU**: Defaults to `false` (skip processing)
- **BOTTOMMENU_ITEMS**: Logs warning and skips processing

## Integration with Workflow

### iOS Workflow Integration

- **Stage 1**: `branding_assets.sh` runs first in iOS workflow
- **Automatic**: Custom icons processed before app icon generation
- **Dependencies**: Icons available for subsequent stages

### Environment Variable Flow

1. **API Call**: Sets `IS_BOTTOMMENU` and `BOTTOMMENU_ITEMS`
2. **branding_assets.sh**: Processes custom icons
3. **Subsequent Stages**: Use downloaded icons

## Testing

### Test Script

- **File**: `test_custom_icons_branding.sh`
- **Coverage**: All scenarios and edge cases
- **Execution**: `bash test_custom_icons_branding.sh`

### Test Cases

1. **IS_BOTTOMMENU=false**: Should skip processing
2. **JSON Format**: Should process custom icons
3. **Legacy Format**: Should process legacy items
4. **Empty Items**: Should handle gracefully
5. **Mixed Types**: Should process custom, skip default

## Benefits

### 1. Conditional Processing

- **Performance**: Skips unnecessary processing when disabled
- **Flexibility**: Can enable/disable per build
- **Clean**: No side effects when disabled

### 2. JSON Format

- **Structured**: Clear separation of type, label, and icon
- **Extensible**: Easy to add new fields
- **Validation**: Better error handling

### 3. SVG Support

- **Scalable**: Vector icons for all screen sizes
- **Modern**: Industry standard format
- **Efficient**: Smaller file sizes

### 4. Backward Compatibility

- **Legacy Support**: Still supports old format
- **Migration**: Gradual transition possible
- **No Breaking Changes**: Existing workflows continue

## Migration Guide

### From Legacy Format

**Old**:

```bash
export BOTTOMMENU_ITEMS="https://example.com/home.png:Home"
```

**New**:

```bash
export IS_BOTTOMMENU="true"
export BOTTOMMENU_ITEMS='[{"type":"custom","label":"Home","icon_url":"https://example.com/home.svg"}]'
```

### Adding Custom Icons

1. Set `IS_BOTTOMMENU="true"`
2. Format `BOTTOMMENU_ITEMS` as JSON array
3. Add `"type": "custom"` for items needing icons
4. Provide `icon_url` for custom items

## Troubleshooting

### Common Issues

#### Icons Not Downloading

- Check `IS_BOTTOMMENU` is set to `"true"`
- Verify `icon_url` is accessible
- Check network connectivity

#### JSON Parsing Errors

- Ensure valid JSON format
- Check for missing quotes or brackets
- Verify `jq` is installed (optional)

#### File Permission Issues

- Ensure `assets/icons/` directory is writable
- Check script execution permissions

### Debug Mode

```bash
# Enable verbose logging
export DEBUG=true
bash lib/scripts/ios/branding_assets.sh
```

## Future Enhancements

### Potential Improvements

1. **Icon Validation**: Verify downloaded icons are valid SVG
2. **Icon Optimization**: Compress SVG files
3. **Multiple Formats**: Support PNG, WebP, etc.
4. **Icon Caching**: Avoid re-downloading existing icons
5. **Icon Previews**: Generate preview images

### Configuration Options

1. **Icon Size**: Specify target icon dimensions
2. **Icon Quality**: Set compression levels
3. **Download Timeout**: Configure timeout values
4. **Retry Logic**: Customize retry attempts

## Conclusion

The enhanced custom icons functionality provides a robust, flexible solution for managing bottom menu icons in the iOS branding workflow. The conditional processing ensures optimal performance while the JSON format offers better structure and extensibility.

**Key Success Factors:**

- ✅ Conditional processing with `IS_BOTTOMMENU`
- ✅ JSON format support for structured data
- ✅ SVG icon download and management
- ✅ Backward compatibility with legacy format
- ✅ Comprehensive error handling and fallbacks
- ✅ Integration with existing iOS workflow

This enhancement makes the branding assets script more powerful and user-friendly while maintaining compatibility with existing workflows.
