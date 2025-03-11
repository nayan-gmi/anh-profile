<?php


/**
 * Implements hook_theme().
 */
/**
 * Tempaltes for paragraphs.
 * @param mixed $existing
 * @param mixed $type
 * @param mixed $theme
 * @param mixed $path
 * @return array{base hook: string, path: string[]}
 */
function gmi_starter_kit_theme($existing, $type, $theme, $path): array
{   
    $templates = [];

    if (!\Drupal::moduleHandler()->moduleExists('paragraphs')) {
        return $templates; // Return empty if the module is not enabled.
    }
    
    // Get all paragraph types.
    $paragraph_types = \Drupal::entityTypeManager()->getStorage('paragraphs_type')->loadMultiple();
    $template_directory = "{$path}/templates/paragraph";

    foreach ($paragraph_types as $paragraph_type) {
        $type_id = $paragraph_type->id();
        $type_id_for_templates = str_replace('_', '-', $type_id);
        $base_template_file = "{$template_directory}/{$type_id}/paragraph--{$type_id_for_templates}.html.twig";

        // Base template for paragraph type.
        if (file_exists($base_template_file)) {
            $templates["paragraph__{$type_id}"] = [
                'base hook' => 'paragraph',
                'path' => "{$template_directory}/{$type_id}",
            ];
        }

        // Fetch only the view modes for the current paragraph type.
        $view_modes = \Drupal::entityTypeManager()
            ->getStorage('entity_view_display')
            ->loadByProperties([
                'targetEntityType' => 'paragraph',
                'bundle' => $type_id,
                'status' => true,
        ]);

        // Loop through the filtered view modes.
        foreach ($view_modes as $view_mode) {
            $view_mode_id = $view_mode->getMode();
            $view_mode_id_for_templates = str_replace('_', '-', $view_mode_id);
            $view_mode_template_file = "{$template_directory}/{$type_id}/paragraph--{$type_id_for_templates}--{$view_mode_id_for_templates}.html.twig";

            if (file_exists($view_mode_template_file)) {
                $templates["paragraph__{$type_id}__{$view_mode_id}"] = [
                    'base hook' => 'paragraph',
                    'path' => "{$template_directory}/{$type_id}",
                ];
            }
        }
    }

    return $templates;
}



function gmi_starter_kit_preprocess(&$variables, $hook)
{
    $path_resolver = \Drupal::service('extension.path.resolver');
    $profile_base_path = $path_resolver->getPath('profile', 'gmi_starter_kit');
    $variables['base_path'] = '/' . $profile_base_path;
}