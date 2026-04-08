class TemplateUtils {
  static String fill(String template, Map<String, Object> values) {
    String result = template;

    values.forEach((String key, Object value) {
      result = result.replaceAll('{$key}', '$value');
    });

    return result;
  }
}
