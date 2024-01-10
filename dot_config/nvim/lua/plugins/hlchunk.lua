require("hlchunk").setup({
  chars = {
    horizontal_line = "─",
    vertical_line = "│",
    left_top = "╭",
    left_bottom = "╰",
    right_arrow = ">",
  },
  chunk = {
    notify = false,
    style = {
      { fg = "#ffac59" },
      { fg = "#808080" }
    }
  },
  line_num = {
    style = "#ffac59"
  },
  blank = {
    chars = {
      ""
    }
  }
})
