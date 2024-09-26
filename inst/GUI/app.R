library(shiny)
library(miniUI)

ui <- miniPage(
  gadgetTitleBar("Ocsai GUI",
    left = miniTitleBarCancelButton()
  )
)

server <- function(input, output, session) {}

runGadget(ui, server)