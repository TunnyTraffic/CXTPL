#pragma once

#include <functional>
#include <memory>

#if defined CXTPL_FS
// __has_include is currently supported by GCC and Clang. However GCC 4.9 may have issues and
// returns 1 for 'defined( __has_include )', while '__has_include' is actually not supported:
// https://gcc.gnu.org/bugzilla/show_bug.cgi?id=63662
#if __has_include(<filesystem>)
#include <filesystem>
#else
#include <experimental/filesystem>
#endif
#endif

#include "core/defaults/defaults.hpp"
#include "core/tags.hpp"
#include "core/errors/errors.hpp"

namespace CXTPL {

namespace core {

#if defined CXTPL_FS
#if __has_include(<filesystem>)
namespace fs = std::filesystem;
#else
namespace fs = std::experimental::filesystem;
#endif // __has_include
#endif // CXTPL_FS

struct GeneratorTags {
  const char* openTagStart =
    defaults::DefaultTags::openTagStart;

  PairTag code_block
    = defaults::DefaultTags::code_block;

  PairTag code_line
    = defaults::DefaultTags::code_line;

  PairTag code_append_raw
    = defaults::DefaultTags::code_append_raw;

  PairTag code_append_as_string
    = defaults::DefaultTags::code_append_as_string;
};

/// \brief used to generate C++ code from template
class Generator {
 public:
  struct Position {
    long int index;
  };

  struct EncloseTagResult {
    std::string tagCode;
  };

#if defined CXTPL_FS
  /// \brief used to generate C++ code from .cxtpl template file
  std::string generate(const fs::path& template_filepath) noexcept;
#endif

  /// \brief used to generate C++ code from template string
  outcome::result<std::string, errors::GeneratorErrorExtraInfo> generate(const char* template_source) noexcept;

  /// \brief used to modify parser tags
  GeneratorTags& supported_tags() noexcept;

  /// \brief used to change parser tags
  void set_supported_tags(const GeneratorTags&) noexcept;

 private:
  /// \brief will be called when we found `openTagStart`
  outcome::result<void, errors::GeneratorErrorExtraInfo> handleTagStart(
    std::string_view& str, Generator::Position& pos, std::string& resultStr);

  /// \brief will be called when we found supported tag after `openTagStart`
  outcome::result<void, errors::GeneratorErrorExtraInfo> handleTag(
      std::string_view& str, const PairTag& tag,
      Generator::Position& curPos, std::string& resultStr);

  outcome::result<EncloseTagResult, errors::GeneratorErrorExtraInfo> encloseTag(
      std::string_view& processStr, Generator::Position& curPos,
      const std::string& startTag, const std::string& closeTag);

  outcome::result<std::string, errors::GeneratorErrorExtraInfo>
    generateFromString();

 private:
  GeneratorTags GeneratorTags_;

  ///\note used only for debug output
  std::string_view original_str;
};

} // namespace core

} // namespace CXTPL
