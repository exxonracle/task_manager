from sqlalchemy import Column, Integer, String, Date, ForeignKey
from database import Base

class Task(Base):
    __tablename__ = "tasks"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    description = Column(String)
    due_date = Column(Date)
    due_time = Column(String)
    status = Column(String, default="To-Do")
    blocked_by_id = Column(Integer, ForeignKey("tasks.id"), nullable=True)
