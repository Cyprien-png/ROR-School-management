class Student < Person
  enum :status, {
    in_formation: 0,
    stopped: 1,
    finished: 2
  }
end
