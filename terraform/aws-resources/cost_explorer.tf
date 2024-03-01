resource "aws_ce_anomaly_monitor" "default" {
  name                  = "default"
  monitor_dimension     = "SERVICE"
  monitor_type          = "DIMENSIONAL"
  monitor_specification = null
}

resource "aws_ce_anomaly_subscription" "default" {
  name             = "default"
  monitor_arn_list = [aws_ce_anomaly_monitor.default.arn]
  frequency        = "DAILY"

  subscriber {
    type    = "EMAIL"
    address = "liam@liam.sh"
  }

  threshold_expression {
    or {
      dimension {
        key           = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
        match_options = ["GREATER_THAN_OR_EQUAL"]
        values        = ["10"]
      }
    }
    or {
      dimension {
        key           = "ANOMALY_TOTAL_IMPACT_PERCENTAGE"
        match_options = ["GREATER_THAN_OR_EQUAL"]
        values        = ["25"]
      }
    }
  }
}
