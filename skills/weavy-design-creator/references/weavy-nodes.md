# Weavy Nodes & Prompt Reference

## Node Types

| Node | Purpose | Notes |
|------|---------|-------|
| Text Prompt | Main image generation instruction | Keep under 120 tokens |
| System Prompt | Persistent campaign style instruction | Shared across all assets in a campaign |
| Image Input | Reference image for style anchoring | URL or uploaded file |
| Style Reference | ControlNet-style visual consistency | Use campaign reference_image_url if provided |
| Aspect Ratio | Output dimensions | "1:1" \| "16:9" \| "9:16" \| "4:5" |
| Negative Prompt | Exclusions from generation | Always set; see defaults below |
| Seed | Reproducibility across assets | Optional; set for consistency across variants |
| Model Selector | AI model choice | "flux" \| "stable-diffusion" \| "recraft" |

## System Prompt Template

Fill this template for each campaign. Keep the final string under 200 tokens.

```
You are generating visuals for [campaign_name].
Style: [brief]. Colors: [hex list]. Avoid: [negative_prompts].
Maintain visual consistency across all assets in this campaign.
```

Example (GreenNode GPU launch):
```
You are generating visuals for GreenNode April Launch.
Style: Dark cinematic, techy, futuristic. Colors: #6B2FFA, #1A1A2E. Avoid: logos, text, stock photo aesthetic.
Maintain visual consistency across all assets in this campaign.
```

## Text Prompt Construction Rules

Build prompts in this order:
1. **Environment/Setting** — where or what space
2. **Lighting/Color** — dominant palette and light source
3. **Composition** — how the frame is organized
4. **Style label** — aesthetic shorthand (e.g., "editorial", "cinematic", "flat vector")

Keep under 120 tokens. Longer prompts reduce model coherence.

## Prompt Patterns by Campaign Type

### Product Launch
```
Clean studio environment, [primary_color] accent lighting, product hero shot centered,
minimal gradient background, professional product photography, [format] composition
```

### Thought Leadership
```
Abstract minimal composition, muted [primary_color] palette, generous white space,
typographic hierarchy suggestion, editorial design aesthetic, [format] layout
```

### Community / Event
```
Warm energetic atmosphere, people-implied silhouettes at mid-ground,
bold [primary_color] accent band at lower third, vibrant celebratory mood,
[format] composition for social
```

### GPU / Tech Product (GreenNode default)
```
Dark cinematic environment, [primary_color] neon data streams and geometric nodes,
floating server rack abstraction, dramatic side lighting, futuristic tech aesthetic,
[format] hero composition
```

### Social Media Engagement
```
Bold graphic design, high contrast, [primary_color] dominant color block,
clean typographic space reserved at top, scroll-stopping composition,
mobile-optimized [format] framing
```

## Negative Prompt Defaults

Always append to campaign negative_prompts unless user overrides:
```
blurry, low quality, watermark, text overlay, cluttered background, oversaturated,
cartoon, anime, stock photo, generic, amateur
```

## Format → Composition Notes

| Format | Composition Guidance |
|--------|---------------------|
| 1:1 | Square center-weighted, safe zone 80% of frame |
| 16:9 | Wide cinematic, rule of thirds, landscape |
| 9:16 | Vertical mobile-first, top 30% is headline space |
| 4:5 | Instagram portrait, subject upper-center |
